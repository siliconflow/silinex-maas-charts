Silinex MaaS Frontend Helm Chart
================================

资源
----

- Deployment/Service: silinex-maas-frontend
- 默认 Service 类型: ClusterIP
- 默认端口: 16101
- 默认 nodeSelector: kubernetes.io/hostname=dev-vm-120

安装
----

    helm upgrade --install silinex-maas-frontend ./silinex-maas-frontend \
      --create-namespace \
      --namespace maas

常用覆盖参数
------------

    --set config.BASE_URL=http://silinex-maas-server:16100/silinex
    --set config.AUTH_CALLBACK_URL=https://10.60.30.120:31300
    --set config.LOGTO_ENDPOINT=https://10.60.30.120:31301/
    --set config.LOGTO_APP_ID=<logto-app-id>
    --set config.COOKIE_DOMAIN=<cookie-domain-or-empty>
    --set secrets.LOGTO_APP_SECRET=<logto-app-secret>
    --set secrets.LOGTO_COOKIE_SECRET=<cookie-secret>
    --set nodeSelector."kubernetes\\.io/hostname"=<k8s-node-name>

默认会可选挂载 silinex-maas-nginx-tls 里的 nginx-chain.pem 到 /ssl/nginx-chain.pem，匹配 NODE_EXTRA_CA_CERTS。Secret 不存在时 frontend 仍会启动，不再强依赖 nginx 先安装。

验证
----

    kubectl get deploy -n maas silinex-maas-frontend
    kubectl get svc -n maas silinex-maas-frontend
    kubectl logs -n maas deploy/silinex-maas-frontend

卸载
----

    helm uninstall silinex-maas-frontend -n maas
