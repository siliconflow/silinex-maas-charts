Logto Helm Chart
================

安装
----

在 silinex-maas-charts 目录执行:

    helm install logto ./logto --create-namespace --namespace sf-maas

如需覆盖外部访问地址:

    helm install logto ./logto --create-namespace --namespace sf-maas \
      --set global.managementPlane.host=<management-plane-ip>

访问
----

App:   https://<management-plane-ip>:31301
Admin: https://<management-plane-ip>:31302

主要默认配置
------------

Logto 镜像: registry.inner.silinex.work/silinex-maas/logto:1.28.0-amd64

Logto DB: postgres://silinex:***@pg-prod-rw:5432/maas_idp_test

Service 使用 ClusterIP，外部 HTTPS 由 silinex-maas-nginx 暴露:
- logto app:   16001
- logto admin: 16002

验证
----

    kubectl get pods -n sf-maas -l app.kubernetes.io/instance=logto
    kubectl get svc -n sf-maas logto

卸载
----

    helm uninstall logto -n sf-maas
