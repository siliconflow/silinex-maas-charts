LWS (LeaderWorkerSet) Helm Chart
=================================

简介
----
LWS (LeaderWorkerSet) 是 Kubernetes SIGs 的一个 API，用于部署一组 Pod 作为复制单元，特别适用于 AI/ML 推理工作负载。

快速开始
--------
安装

    helm install lws ./lws-chart --create-namespace --namespace lws-system

或显式覆盖镜像仓库前缀安装

    helm install lws ./lws-chart --set global.imageRegistry=<customer-registry> --create-namespace --namespace lws-system

验证安装

    kubectl get pods -n lws-system

卸载

    helm uninstall lws -n lws-system

配置说明
--------
镜像配置

默认使用内网镜像：
- 镜像地址：registry.inner.silinex.work/silinex-maas/lws
- Tag: v0.8.0

默认已经使用 `global.imageRegistry: registry.inner.silinex.work/silinex-maas` 作为统一前缀。如需切换客户仓库，直接覆盖该前缀：

    helm install lws ./lws-chart --set global.imageRegistry=<customer-registry>/silinex-maas

`values-private.yaml` 保留为兼容入口，效果等同于默认内网前缀：
- 镜像地址：registry.inner.silinex.work/silinex-maas/lws
- Tag: v0.8.0

主要配置项
----------
配置项                    默认值                      说明
replicaCount              1                          副本数量
global.imageRegistry      registry.inner.silinex.work/silinex-maas  镜像统一前缀
image.manager.repository  lws                                      镜像名
image.manager.tag         v0.8.0                     镜像版本
service.type              ClusterIP                  服务类型
service.port              9443                       服务端口
resources.requests.cpu    1                          CPU 请求
resources.requests.memory 1Gi                        内存请求

更多信息
--------
官方文档：https://lws.sigs.k8s.io/
GitHub：https://github.com/kubernetes-sigs/lws
