# Silinex MaaS 部署顺序

以下命令默认在 `silinex-maas-charts` 目录执行，业务命名空间统一使用 `sf-maas`。

## 镜像仓库前缀

所有 Helm chart 默认使用统一镜像目录 `registry.inner.silinex.work/silinex-maas/<镜像名>:<tag>`。公共镜像和第三方组件也需要先搬运到这个目录，chart 中默认使用统一镜像前缀:

```yaml
global:
  imageRegistry: registry.inner.silinex.work/silinex-maas
```

迁移到客户环境时，保持各 chart 内的 `image.repository: <镜像名>` 不变，只需要在安装或升级时统一覆盖前缀，例如:

```bash
--set global.imageRegistry=<customer-registry>/silinex-maas
```

镜像按 amd64/x86_64 准备；chart 中可调度的工作负载默认带 `sf-maas-deploy: "true"` 节点选择。部署前需要先选好承载 MaaS 的节点并打标:

```bash
kubectl label node <node-name> sf-maas-deploy=true
```

客户环境里管控面地址通过各 chart 的 `global.managementPlane.host` 覆盖，默认值是 `10.60.30.120`。

## 1. PostgreSQL

先安装 CloudNativePG operator:

```bash
helm upgrade --install postgres-operator ./postgresql/cloudnative-pg \
  --namespace cnpg-system \
  --create-namespace
```

再创建 MaaS 内部 PostgreSQL 集群和业务库:

```bash
kubectl create namespace sf-maas --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f postgresql/pg-secret.yaml
kubectl apply -f postgresql/pg-cluster.yaml
kubectl apply -f postgresql/pg-databases.yaml
```

检查:

```bash
kubectl -n sf-maas get cluster pg-prod
kubectl -n sf-maas get pods -l cnpg.io/cluster=pg-prod
kubectl -n sf-maas get svc pg-prod-rw
```

## 2. Redis

安装内部 Redis Sentinel:

```bash
helm upgrade --install redis-cache ./redis \
  --namespace sf-maas \
  --create-namespace \
  -f ./redis/cache-values.yaml
```

检查:

```bash
kubectl -n sf-maas get pod -l app.kubernetes.io/instance=redis-cache
kubectl -n sf-maas exec redis-cache-node-0 -c sentinel -- \
  redis-cli -p 26379 sentinel get-master-addr-by-name redis-cache-master
```

## 3. Logto 和入口

先装 Logto:

```bash
helm upgrade --install logto ./logto \
  --namespace sf-maas \
  --create-namespace
```

再装 nginx 入口，方便访问 Logto 控制台:

```bash
helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
  --namespace sf-maas \
  --create-namespace
```

nginx 可以先于 MaaS 后端、前端和文档服务启动；这些上游未部署前，对应路径会临时返回 502。

检查:

```bash
kubectl -n sf-maas get svc logto silinex-maas-nginx
kubectl -n sf-maas get pods -l app.kubernetes.io/instance=logto
```

## 4. 人工创建 Logto 应用

登录 Logto 控制台后，人工创建两套应用并记录 `appid/secret`:

- M2M 应用: 给 `silinex-maas-server` 管理 Logto 用
- Web/App 应用: 给 `silinex-maas-frontend` 登录用

然后回填到 values 或安装命令:

```bash
# 后端需要 M2M appid/secret
--set logto.managementAppId=<m2m-app-id>
--set logto.managementAppSecret=<m2m-app-secret>

# 前端需要 Web/App appid/secret
--set config.LOGTO_APP_ID=<app-id>
--set secrets.LOGTO_APP_SECRET=<app-secret>
```

## 5. 后端、模型下载、前端和文档

先装模型下载服务:

```bash
helm upgrade --install silinex-model-downloader ./silinex-model-downloader \
  --namespace sf-maas \
  --create-namespace --set persistence.type=nfs --set persistence.nfs.server=<nfs-server-ip> --set persistence.nfs.path=/srv/nfs/test/
```

再装后端。升级时建议先删除旧 init Job，避免 Job template 不可变导致 Helm upgrade 失败:

```bash
kubectl -n sf-maas delete job silinex-maas-server-init --ignore-not-found --wait=true

helm upgrade --install silinex-maas-server ./silinex-maas-server \
  --namespace sf-maas \
  --create-namespace \
  --set logto.managementAppId=<m2m-app-id> \
  --set logto.managementAppSecret=<m2m-app-secret>
```

再装前端和文档:

```bash
helm upgrade --install silinex-maas-frontend ./silinex-maas-frontend \
  --namespace sf-maas \
  --create-namespace \
  --set config.LOGTO_APP_ID=<app-id> \
  --set secrets.LOGTO_APP_SECRET=<app-secret>

helm upgrade --install silinex-maas-docs ./silinex-maas-docs \
  --namespace sf-maas \
  --create-namespace
```

检查:

```bash
kubectl -n sf-maas get pods
kubectl -n sf-maas logs job/silinex-maas-server-init
kubectl -n sf-maas get deploy silinex-maas-server silinex-maas-frontend silinex-maas-docs
kubectl -n sf-maas get svc silinex-maas-nginx
```

## 注意

- PostgreSQL 默认使用 `pg-prod-rw:5432`。
- Redis 默认使用 Sentinel: `redis-cache:26379`，master set 为 `redis-cache-master`。
- `silinex-maas-server` 必须等 Logto M2M 应用创建后再安装或升级。
- `silinex-maas-frontend` 必须等 Logto Web/App 应用创建后再安装或升级。
- `pg-cluster.yaml` 默认使用 `storageClass: local-path`，部署前确认集群存在该 StorageClass。
- `silinex-model-downloader` 默认使用 `hostPath /maasjfs`，如果要使用 NFS，需要额外设置 `persistence.type=nfs` 和 NFS 地址。
