#!/usr/bin/env bash
set -euo pipefail


kubectl apply -f infra/k8s/metrics/metrics-deployment.yaml
kubectl apply -f infra/k8s/metrics/metrics-service.yaml
kubectl apply -f infra/k8s/metrics/metrics-networkpolicy.yaml
# optional check
kubectl get pods -l app=metrics"
kubectl get svc metrics-service"
