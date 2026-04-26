
# 安装

推荐 release 名固定为 redis-cache，后端 chart 默认会连接这个服务名:

```bash
helm upgrade --install redis-cache . \
  --namespace maas \
  --create-namespace \
  -f cache-values.yaml
```

# 当前模式

`cache-values.yaml` 使用 replication + Sentinel:

- Sentinel Service: `redis-cache:26379`
- Redis Service: `redis-cache:6379`
- Headless Service: `redis-cache-headless`
- StatefulSet: `redis-cache-node`
- Sentinel master set: `redis-cache-master`
- Redis password: `silicon@123`
- Sentinel auth: disabled

# 验证

```bash
kubectl -n maas get svc | grep redis-cache
kubectl -n maas get pod -l app.kubernetes.io/instance=redis-cache

kubectl -n maas exec -it redis-cache-node-0 -c sentinel -- \
  redis-cli -p 26379 sentinel get-master-addr-by-name redis-cache-master

kubectl -n maas exec -it redis-cache-node-0 -c redis -- \
  redis-cli -a 'silicon@123' info replication | grep role
```


