# Silinex MaaS 部署顺序

以下命令默认在 `silinex-maas-charts` 目录执行，业务命名空间统一使用 `sf-maas`。

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

## 3. 基础业务服务

先装 Logto:

```bash
helm upgrade --install logto ./logto \
  --namespace sf-maas \
  --create-namespace
```

再装模型下载服务:

```bash
helm upgrade --install silinex-model-downloader ./silinex-model-downloader \
  --namespace sf-maas \
  --create-namespace
```

最后装后端。升级时建议先删除旧 init Job，避免 Job template 不可变导致 Helm upgrade 失败:

```bash
kubectl -n sf-maas delete job silinex-maas-server-init --ignore-not-found --wait=true

helm upgrade --install silinex-maas-server ./silinex-maas-server \
  --namespace sf-maas \
  --create-namespace
```

检查:

```bash
kubectl -n sf-maas get pods
kubectl -n sf-maas logs job/silinex-maas-server-init
kubectl -n sf-maas get deploy silinex-maas-server
```

## 4. 前端、文档和入口

```bash
helm upgrade --install silinex-maas-frontend ./silinex-maas-frontend \
  --namespace sf-maas \
  --create-namespace

helm upgrade --install silinex-maas-docs ./silinex-maas-docs \
  --namespace sf-maas \
  --create-namespace

helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
  --namespace sf-maas \
  --create-namespace
```

检查入口:

```bash
kubectl -n sf-maas get svc silinex-maas-nginx
```

## 注意

- PostgreSQL 默认使用 `pg-prod-rw:5432`。
- Redis 默认使用 Sentinel: `redis-cache:26379`，master set 为 `redis-cache-master`。
- `pg-cluster.yaml` 默认使用 `storageClass: local-path`，部署前确认集群存在该 StorageClass。
- `silinex-model-downloader` 默认使用 `hostPath /maasjfs`，如果要使用 NFS，需要额外设置 `persistence.type=nfs` 和 NFS 地址。
