Logto Helm Chart
================

安装
----

在 silinex-maas-charts 目录执行:

    helm install logto ./logto --create-namespace --namespace maas

如需覆盖外部访问地址:

    helm install logto ./logto --create-namespace --namespace maas \
      --set logto.endpoint=http://<node-ip>:31301 \
      --set logto.adminEndpoint=http://<node-ip>:31302

访问
----

App:   http://10.60.30.120:31301
Admin: http://10.60.30.120:31302

主要默认配置
------------

Logto 镜像: registry.inner.silinex.work/silinex-maas/logto:1.28.0-amd64

Logto DB: postgres://postgres:postgres123@10.60.30.101:17032/maas_idp_test

Service 使用 NodePort:
- logto app:   31301 -> 16001
- logto admin: 31302 -> 16002

验证
----

    kubectl get pods -n maas -l app.kubernetes.io/instance=logto
    kubectl get svc -n maas logto

卸载
----

    helm uninstall logto -n maas
