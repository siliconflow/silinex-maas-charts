Silinex Model Downloader Helm Chart
===================================

资源
----

- Deployment/Service/PV/PVC: silinex-model-downloader
- 默认 Service 类型: ClusterIP
- 默认 Service 端口: 16102 -> 容器 8000
- 默认 nodeSelector: sf-maas-deploy=true
- 默认存储: hostPath /maasjfs -> /data/models
- NFS 可选: 10.191.59.2:/data-models -> /data/models

安装
----

    helm upgrade --install silinex-model-downloader ./silinex-model-downloader \
      --create-namespace \
      --namespace sf-maas

常用覆盖参数
------------

    --set database.name=silinex_download_test
    --set database.url=postgresql://silinex:<password>@pg-prod-rw:5432/silinex_download_test
    --set authTokens.modelScope=<modelscope-token>
    --set authTokens.huggingFace=<huggingface-token>
    --set persistence.type=hostPath
    --set persistence.hostPath.path=/maasjfs
    --set nodeSelector.<label-key>=<label-value>

如果确认节点可以直接挂载 NFS，再启用 NFS PV/PVC:

    --set persistence.type=nfs
    --set persistence.nfs.server=10.191.59.2
    --set persistence.nfs.path=/data-models

如果集群里已经有 PVC:

    --set persistence.createPV=false \
    --set persistence.createPVC=false \
    --set persistence.existingClaim=<pvc-name>

后端服务连接地址
----------------

    http://silinex-model-downloader:16102

验证
----

    kubectl get pv silinex-model-downloader-nfs
    kubectl get pvc -n sf-maas silinex-model-downloader-models
    kubectl get deploy -n sf-maas silinex-model-downloader
    kubectl get svc -n sf-maas silinex-model-downloader
    kubectl logs -n sf-maas deploy/silinex-model-downloader
    kubectl -n sf-maas exec deploy/silinex-model-downloader -- df -h /data/models

NFS FailedMount 排查
-------------------

如果使用 NFS 模式并出现:

    MountVolume.SetUp failed ... mount.nfs: Connection timed out

说明 Pod 所在节点到 NFS 服务不通，或 NFS 版本/导出路径不匹配。先在调度节点上验证:

    nc -vz 10.191.59.2 2049
    showmount -e 10.191.59.2
    mount -t nfs -o nfsvers=3,nolock,rw,soft,tcp 10.191.59.2:/data-models /mnt

如果节点已把共享模型目录预挂载到本地路径，推荐用默认 hostPath 模式，并确保:

    ls -ld /maasjfs

卸载
----

    helm uninstall silinex-model-downloader -n sf-maas

默认 PV 回收策略是 Retain，卸载 Helm release 不会删除 NFS 上的模型文件。
