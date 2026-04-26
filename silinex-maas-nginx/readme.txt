Silinex MaaS Nginx Helm Chart
=============================

用途
----

给 MaaS 提供一个独立 nginx 入口:

- 聚合入口:    https://<management-plane-ip>:31300
- Logto app:   https://<management-plane-ip>:31301 -> http://logto:16001
- Logto admin: https://<management-plane-ip>:31302 -> http://logto:16002

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

默认随 chart 带的证书适配默认管控面地址。客户环境如调整 `global.managementPlane.host`，需要同时提供匹配的 TLS 证书文件或 Secret。浏览器仍需要信任签发这个证书的内部 CA。

安装顺序
--------

nginx 已使用运行时 DNS 解析，可以在 silinex-maas-server、silinex-maas-frontend、silinex-maas-docs 之前安装。未部署的上游在被访问时会返回 502，但不会阻塞 nginx 启动。

先把 Logto 改成 ClusterIP，并把 Logto 自己的 endpoint 改成 HTTPS:

    helm upgrade --install logto ./logto \
      --namespace sf-maas \
      --set service.type=ClusterIP \
      --set global.managementPlane.host=<management-plane-ip>

再安装 nginx:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace sf-maas \
      --set global.managementPlane.host=<management-plane-ip>

如需固定 nginx Pod 到某个节点:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace sf-maas \
      --set nodeName=<k8s-node-name>

默认 nodeSelector 使用部署标签:

    nodeSelector:
      sf-maas-deploy: "true"

部署前需要先给目标节点打标:

    kubectl label node <k8s-node-name> sf-maas-deploy=true

如需改到其它选择器:

    helm upgrade --install silinex-maas-nginx ./silinex-maas-nginx \
      --namespace sf-maas \
      --set nodeSelector.<label-key>=<label-value>

如果 Logto release 不是 logto，或者 Service 名不同，覆盖 upstream:

    --set upstreams.logtoApp.host=<logto-service> \
    --set upstreams.logtoAdmin.host=<logto-service>

如果 MaaS 服务名或端口不同，覆盖对应 upstream:

    --set upstreams.maasApi.host=<server-service> \
    --set upstreams.maasServer.host=<server-service> \
    --set upstreams.maasFrontend.host=<frontend-service> \
    --set upstreams.maasDocs.host=<docs-service>

如果集群 DNS Service 名不是 kube-system/kube-dns，覆盖 nginx resolver:

    --set nginx.resolver=<dns-service>.<dns-namespace>.svc.cluster.local

验证
----

    kubectl get svc -n sf-maas silinex-maas-nginx
    curl -vk https://<management-plane-ip>:31300
    curl -vk https://<management-plane-ip>:31300/silinex/
    curl -vk https://<management-plane-ip>:31300/documents
    curl -vk https://<management-plane-ip>:31301
    curl -vk https://<management-plane-ip>:31302

卸载
----

    helm uninstall silinex-maas-nginx -n sf-maas
