aws acm request-certificate \
  --domain-name "www.acme.com" \
  --validation-method DNS \
  --region ap-southeast-1

#Output: {
#    "CertificateArn": "arn:aws:acm:ap-southeast-1:637423177844:certificate/78a51722-06fa-4d61-bb28-d9016da85f5f"
#}

kubectl apply -f infra/k8s/ui/ui-deployment.yaml
kubectl apply -f infra/k8s/ui/ui-service.yaml
kubectl apply -f infra/k8s/ui/ui-ingress.yaml
