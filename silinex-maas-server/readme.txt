Silinex MaaS Server Helm Chart
==============================

资源
----

- Deployment/Service: silinex-maas-server
- Init Job: silinex-maas-server-init
- 后端 Service 类型: ClusterIP
- Init Job 不创建 Service

安装
----

先安装 Logto，再安装本 chart:

    helm upgrade --install silinex-maas-server ./silinex-maas-server --create-namespace --namespace sf-maas

如果使用 chart 内的下载管理服务，先安装 silinex-model-downloader，后端默认会连接:

    http://silinex-model-downloader:16102

默认 nodeSelector 使用部署标签，server Deployment 和 init Job 都会调度到带这个标签的节点:

    nodeSelector:
      sf-maas-deploy: "true"

部署前需要先给目标节点打标:

    kubectl label node <k8s-node-name> sf-maas-deploy=true

如需改到其它选择器:

    helm upgrade --install silinex-maas-server ./silinex-maas-server \
      --namespace sf-maas \
      --set nodeSelector.<label-key>=<label-value>

数据库和 Redis
--------------

PostgreSQL 默认使用 chart 内 CloudNativePG 集群:

- postgres.host=pg-prod-rw
- postgres.port=5432
- postgres.user=silinex
- postgres.serverDatabase=silinex_maas_test
- postgres.logtoDatabase=maas_idp_test

后端和 Logto 必须使用不同的 db:

    --set postgres.serverDatabase=<backend-db>
    --set postgres.logtoDatabase=<logto-db>

Redis 使用同一个实例时，后端要使用独立 db:

    --set redis.db=<backend-redis-db>

默认使用 chart 内 Redis Sentinel，按以下命令安装 Redis 时可直接使用:

    helm upgrade --install redis-cache ./redis \
      --namespace sf-maas \
      -f ./redis/cache-values.yaml

后端默认 Redis 参数:

- redis.mode=sentinel
- redis.sentinelMasterName=redis-cache-master
- redis.sentinelAddrs=redis-cache:26379
- redis.sentinelPassword 为空，当前 chart 内 Sentinel 未配置认证
- redis.password=silicon@123，用于连接 Redis master/replica

示例:

    helm upgrade --install silinex-maas-server ./silinex-maas-server \
      --namespace sf-maas \
      --set postgres.serverDatabase=silinex_maas_test \
      --set postgres.logtoDatabase=maas_idp_test \
      --set redis.db=1 \
      --set redis.mode=sentinel \
      --set redis.sentinelMasterName=redis-cache-master \
      --set logto.managementEndpoint=http://logto:16001

常用参数
--------

- postgres.host / postgres.port / postgres.user / postgres.password
- postgres.serverDatabase: 后端业务库
- postgres.logtoDatabase: Logto 库，供后端管理 Logto 时直连读取
- redis.addr / redis.password / redis.db
- redis.mode / redis.sentinelAddrs / redis.sentinelMasterName
- logto.managementEndpoint / logto.managementAppId / logto.managementAppSecret
- global.managementPlane.host: 默认用于生成 config.serverSelfHost
- config.serverSelfHost: 显式覆盖后端自访问地址
- config.modelManagerEndpoint: 默认 http://silinex-model-downloader:16102
- initJob.adminUsername / initJob.adminPassword / initJob.autoMigrate

验证
----

    kubectl get deploy -n sf-maas silinex-maas-server
    kubectl get svc -n sf-maas silinex-maas-server
    kubectl get job -n sf-maas silinex-maas-server-init
    kubectl -n sf-maas exec redis-cache-node-0 -c sentinel -- redis-cli -p 26379 sentinel get-master-addr-by-name redis-cache-master

卸载
----

    helm uninstall silinex-maas-server -n sf-maas
