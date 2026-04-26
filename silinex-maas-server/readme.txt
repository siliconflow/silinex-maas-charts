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

默认使用 Sentinel 模式:

- redis.mode=sentinel
- redis.sentinelMasterName=silinex-redis
- redis.sentinelAddrs=10.60.30.101:17119,10.60.30.102:17119,10.60.30.103:17119
- redis.sentinelPassword 为空，当前 Sentinel 未配置认证
- redis.password=redis123，用于连接 Redis master/replica

示例:

    helm upgrade --install silinex-maas-server ./silinex-maas-server \
      --namespace maas \
      --set postgres.serverDatabase=silinex_maas \
      --set postgres.logtoDatabase=maas_idp_test \
      --set redis.db=1 \
      --set redis.mode=sentinel \
      --set redis.sentinelMasterName=silinex-redis \
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
- config.modelManagerEndpoint
- initJob.adminUsername / initJob.adminPassword / initJob.autoMigrate

验证
----

    kubectl get deploy -n maas silinex-maas-server
    kubectl get svc -n maas silinex-maas-server
    kubectl get job -n maas silinex-maas-server-init

卸载
----

    helm uninstall silinex-maas-server -n maas
