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

    helm upgrade --install silinex-maas-server ./silinex-maas-server --create-namespace --namespace maas

如果使用 chart 内的下载管理服务，先安装 silinex-model-downloader，后端默认会连接:

    http://silinex-model-downloader:16102

默认 nodeSelector 使用节点名 dev-vm-120，server Deployment 和 init Job 都会调度到这个节点:

    nodeSelector:
      kubernetes.io/hostname: dev-vm-120

如需改到其它节点:

    helm upgrade --install silinex-maas-server ./silinex-maas-server \
      --namespace maas \
      --set nodeSelector."kubernetes\\.io/hostname"=<k8s-node-name>

数据库和 Redis
--------------

PostgreSQL 使用同一个实例，但后端和 Logto 必须使用不同的 db:

    --set postgres.serverDatabase=<backend-db>
    --set postgres.logtoDatabase=<logto-db>

Redis 使用同一个实例时，后端要使用独立 db:

    --set redis.db=<backend-redis-db>

默认使用 chart 内 Redis Sentinel，按以下命令安装 Redis 时可直接使用:

    helm upgrade --install redis-cache ./redis \
      --namespace maas \
      -f ./redis/cache-values.yaml

后端默认 Redis 参数:

- redis.mode=sentinel
- redis.sentinelMasterName=redis-cache-master
- redis.sentinelAddrs=redis-cache:26379
- redis.sentinelPassword 为空，当前 chart 内 Sentinel 未配置认证
- redis.password=silicon@123，用于连接 Redis master/replica

示例:

    helm upgrade --install silinex-maas-server ./silinex-maas-server \
      --namespace maas \
      --set postgres.serverDatabase=silinex_maas \
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
- config.serverSelfHost
- config.modelManagerEndpoint: 默认 http://silinex-model-downloader:16102
- initJob.adminUsername / initJob.adminPassword / initJob.autoMigrate

验证
----

    kubectl get deploy -n maas silinex-maas-server
    kubectl get svc -n maas silinex-maas-server
    kubectl get job -n maas silinex-maas-server-init
    kubectl -n maas exec redis-cache-node-0 -c sentinel -- redis-cli -p 26379 sentinel get-master-addr-by-name redis-cache-master

卸载
----

    helm uninstall silinex-maas-server -n maas
