Silinex MaaS Nginx Helm Chart
=============================

用途
----

给 MaaS 提供一个独立 nginx 入口:

- 聚合入口:    https://10.60.30.120:31300
- Logto app:   https://10.60.30.120:31301 -> http://logto:16001
- Logto admin: https://10.60.30.120:31302 -> http://logto:16002

nginx 容器监听端口、Service port、NodePort 都固定使用 31300/31301/31302，不使用 80/443 这类通用端口。

聚合入口路由
------------

- /v1/       -> http://silinex-maas-server:16100
- /silinex/  -> http://silinex-maas-server:16100
- /documents -> http://silinex-maas-docs:16103
- /          -> http://silinex-maas-frontend:16101

证书
----

默认使用 chart 内的证书文件:

- ssl_baoneng_tmp/nginx-chain.pem
- ssl_baoneng_tmp/nginx.key

证书 SAN 已包含 10.60.30.120。浏览器仍需要信任签发这个证书的内部 CA。

安装顺序
--------

先把 Logto 改成 ClusterIP，并把 Logto 自己的 endpoint 改成 HTTPS:

    helm upgrade --install logto ./logto \
      --namespace maas \
      --set service.type=ClusterIP \
      --set logto.endpoint=https://10.60.30.120:31301 \
      --set logto.adminEndpoint=https://10.60.30.120:31302

再安装 nginx:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace maas

如需固定 nginx Pod 到某个节点:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace maas \
      --set nodeName=<k8s-node-name>

默认 nodeSelector 使用节点名 dev-vm-120:

    nodeSelector:
      kubernetes.io/hostname: dev-vm-120

如需改到其它节点:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace maas \
      --set nodeSelector."kubernetes\\.io/hostname"=<k8s-node-name>

如果 Logto release 不是 logto，或者 Service 名不同，覆盖 upstream:

    --set upstreams.logtoApp.host=<logto-service> \
    --set upstreams.logtoAdmin.host=<logto-service>

如果 MaaS 服务名或端口不同，覆盖对应 upstream:

    --set upstreams.maasApi.host=<server-service> \
    --set upstreams.maasServer.host=<server-service> \
    --set upstreams.maasFrontend.host=<frontend-service> \
    --set upstreams.maasDocs.host=<docs-service>

验证
----

    kubectl get svc -n maas silinex-maas-nginx
    curl -vk https://10.60.30.120:31300
    curl -vk https://10.60.30.120:31300/silinex/
    curl -vk https://10.60.30.120:31300/documents
    curl -vk https://10.60.30.120:31301
    curl -vk https://10.60.30.120:31302

卸载
----

    helm uninstall silinex-maas-nginx -n maas
