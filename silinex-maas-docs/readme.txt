Silinex MaaS Docs Helm Chart
============================

资源
----

- Deployment/Service: silinex-maas-docs
- 默认 Service 类型: ClusterIP
- 默认端口: 16103
- 默认 nodeSelector: sf-maas-deploy=true

安装
----

    helm upgrade --install silinex-maas-docs ./silinex-maas-docs \
      --create-namespace \
      --namespace sf-maas

常用覆盖参数
------------

    --set global.managementPlane.host=<management-plane-ip>
    --set config.API_URL=<override-api-url>
    --set-string nodeSelector.sf-maas-deploy=true

验证
----

    kubectl get deploy -n sf-maas silinex-maas-docs
    kubectl get svc -n sf-maas silinex-maas-docs
    kubectl logs -n sf-maas deploy/silinex-maas-docs

卸载
----

    helm uninstall silinex-maas-docs -n sf-maas
