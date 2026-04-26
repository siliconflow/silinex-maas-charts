Traefik Helm Chart 使用说明

========================================

部署

helm install traefik ./traefik

查看状态

kubectl get pods | grep traefik
kubectl get svc | grep traefik

访问

HTTP: 端口 80
HTTPS: 端口 443
Dashboard: 端口 9000

Ingress 使用

创建 Ingress 时指定 ingressClassName:

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  ingressClassName: traefik
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-service
            port:
              number: 80

卸载

helm uninstall traefik