Silinex MaaS PostgreSQL
=======================

本目录包含两部分:

- cloudnative-pg/: CloudNativePG operator Helm chart
- pg-secret.yaml / pg-cluster.yaml: MaaS 内部 PostgreSQL 集群实例
- pg-databases.yaml: Logto 和模型下载服务使用的额外数据库

安装 operator
-------------

    helm upgrade --install postgres-operator ./cloudnative-pg \
      --namespace cnpg-system \
      --create-namespace

安装 PostgreSQL 集群
--------------------

    kubectl create namespace sf-maas --dry-run=client -o yaml | kubectl apply -f -
    kubectl apply -f pg-secret.yaml
    kubectl apply -f pg-cluster.yaml
    kubectl apply -f pg-databases.yaml

默认连接信息
------------

- Host: pg-prod-rw
- Port: 5432
- User: silinex
- Password: silicon@123
- 后端 DB: silinex_maas_test
- Logto DB: maas_idp_test
- 模型下载 DB: silinex_download_test

业务 chart 默认已指向:

    pg-prod-rw:5432

验证
----

    kubectl -n sf-maas get cluster pg-prod
    kubectl -n sf-maas get pods -l cnpg.io/cluster=pg-prod
    kubectl -n sf-maas get svc pg-prod-rw

    kubectl -n sf-maas exec -it pg-prod-1 -- \
      psql -h 127.0.0.1 -U silinex -d silinex_maas_test -c "SELECT current_database();"

    kubectl -n sf-maas run psql-test --rm -it \
      --image=registry.inner.silinex.work/silinex-maas/postgresql:16.9 \
      --restart=Never -- \
      psql -h pg-prod-rw -U silinex -d maas_idp_test -c "SELECT current_database();"

注意
----

pg-cluster.yaml 默认使用 storageClass=local-path。部署前确认集群里有这个 StorageClass:

    kubectl get storageclass

如果没有，修改 pg-cluster.yaml 中的 spec.storage.storageClass。

卸载
----

    kubectl delete cluster pg-prod -n sf-maas
    kubectl delete secret pg-user-password -n sf-maas
    helm uninstall postgres-operator -n cnpg-system
