#!/bin/bash

dir=`pwd`
cd infra
terraform apply -target=module.kubernetes.google_container_cluster.primary -refresh=false
terraform output -raw kubernetes_kubeconfig > "$dir/kubeconfig"

echo ""
echo Created kubeconfig in current dir