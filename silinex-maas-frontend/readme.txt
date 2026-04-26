Silinex MaaS Frontend Helm Chart
================================

资源
----

- Deployment/Service: silinex-maas-frontend
- 默认 Service 类型: ClusterIP
- 默认端口: 16101
- 默认 nodeSelector: sf-maas-deploy=true

安装
----

    helm upgrade --install silinex-maas-frontend ./silinex-maas-frontend \
      --create-namespace \
      --namespace sf-maas

常用覆盖参数
------------

    --set global.managementPlane.host=<management-plane-ip>
    --set config.BASE_URL=http://silinex-maas-server:16100/silinex
    --set config.AUTH_CALLBACK_URL=<override-callback-url>
    --set config.LOGTO_ENDPOINT=<override-logto-endpoint>
    --set config.LOGTO_APP_ID=<logto-app-id>
    --set config.COOKIE_DOMAIN=<cookie-domain-or-empty>
    --set secrets.LOGTO_APP_SECRET=<logto-app-secret>
    --set secrets.LOGTO_COOKIE_SECRET=<cookie-secret>
    --set-string nodeSelector.sf-maas-deploy=true

默认会可选挂载 silinex-maas-nginx-tls 里的 nginx-chain.pem 到 /ssl/nginx-chain.pem，匹配 NODE_EXTRA_CA_CERTS。Secret 不存在时 frontend 仍会启动，不再强依赖 nginx 先安装。

验证
----

    kubectl get deploy -n sf-maas silinex-maas-frontend
    kubectl get svc -n sf-maas silinex-maas-frontend
    kubectl logs -n sf-maas deploy/silinex-maas-frontend

卸载
----

    helm uninstall silinex-maas-frontend -n sf-maas
