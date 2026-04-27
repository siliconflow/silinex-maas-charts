# silinex-node-agent-ascend

Ascend 专用节点标注 agent Helm chart。

默认镜像等价于:

```text
registry.inner.silinex.work/silinex-maas/silinex-node-agent:arm64-d9b781e6-20260426-1857
```

安装:

```bash
helm upgrade --install silinex-node-agent ./silinex-node-agent-ascend \
  --namespace default \
  --create-namespace
```

切换镜像仓库:

```bash
helm upgrade --install silinex-node-agent ./silinex-node-agent-ascend \
  --namespace default \
  --create-namespace \
  --set global.imageRegistry=<registry-prefix> \
  --set image.repository=silinex-node-agent \
  --set image.tag=arm64-d9b781e6-20260426-1857
```

默认 `nodeSelector` 限制为 `kubernetes.io/arch=arm64`，匹配当前 arm64 镜像 tag。

如果 amd64 和 arm64 使用不同镜像 tag，可以启用按架构拆分 DaemonSet:

```bash
helm upgrade --install silinex-node-agent ./silinex-node-agent-ascend \
  --namespace default \
  --create-namespace \
  --set architectureSplit.enabled=true \
  --set architectureSplit.architectures[0].tag=<amd64-tag> \
  --set architectureSplit.architectures[1].tag=<arm64-tag>
```

部署到指定 Ascend 节点时，先给节点打标，再设置 nodeSelector:

```bash
kubectl label node <node-name> accelerator=ascend

helm upgrade --install silinex-node-agent ./silinex-node-agent-ascend \
  --namespace default \
  --create-namespace \
  --set-string nodeSelector.accelerator=ascend
```
