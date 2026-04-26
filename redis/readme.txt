
# 安装
helm install redis-cache . -f cache-values.yaml



# 查看 node-0 的角色
kubectl exec -it redis-mq-node-0 -c redis -- redis-cli info replication | grep role

# 查看 node-1 的角色
kubectl exec -it redis-mq-node-1 -c redis -- redis-cli info replication | grep role

kubectl exec -it redis-mq-node-2 -c redis -- redis-cli info replication | grep role

[root@ecs-57004775-001 /data/wangchuxiang/redis]#  kubectl exec -it redis-mq-node-0 -c redis -- redis-cli set MQ_TEST_KEY "hello_redis"
OK
[root@ecs-57004775-001 /data/wangchuxiang/redis]#  kubectl exec -it redis-mq-node-2 -c redis -- redis-cli get MQ_TEST_KEY
"hello_redis"


[root@ecs-57004775-001 /data/wangchuxiang/redis]#  kubectl get svc | grep redis-mq
redis-mq                               ClusterIP   10.99.95.168     <none>        6379/TCP,26379/TCP   6m46s
redis-mq-headless                      ClusterIP   None             <none>        6379/TCP,26379/TCP   6m46s
redis-mq-metrics                       ClusterIP   10.103.109.243   <none>        9121/TCP             6m46s



