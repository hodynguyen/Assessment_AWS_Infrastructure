aws acm request-certificate \
  --domain-name "api.acme.com" \
  --validation-method DNS \
  --region ap-southeast-1

kubectl apply -f infra/k8s/api/api-secret.yaml
kubectl apply -f infra/k8s/api/api-deployment.yaml
kubectl apply -f infra/k8s/api/api-service.yaml
kubectl apply -f infra/k8s/api/api-hpa.yaml
kubectl apply -f infra/k8s/api/api-ingress.yaml

# optional check
kubectl get pods -l app=api
kubectl get svc api-service
kubectl get ingress api-ingress
