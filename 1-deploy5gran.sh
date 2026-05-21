#!/usr/bin/env bash
#Author: fenar

# for some reason the communication doesn't work if deployed in a different namespace.
# Need to investigate further.
# oc new-project open5gran

oc adm policy add-scc-to-user anyuid -z default -n open5gcore
oc adm policy add-scc-to-user hostaccess -z default -n open5gcore
oc adm policy add-scc-to-user hostmount-anyuid -z default -n open5gcore
oc adm policy add-scc-to-user privileged -z default -n open5gcore
current_dir=$PWD
cd 5gran
## gNB Section
echo "Preparing gNB config"
oc get services -n open5gcore | grep amf-open5gs-sctp | awk '{print $3}' > amf-ip
echo "AMF IP:" && cat amf-ip
cp templates/5gran-gnb-configmap.bak templates/5gran-gnb-configmap.yaml
cp templates/5gran-ue-configmap.bak templates/5gran-ue-configmap.yaml
AMF_IP=$(cat amf-ip) && tmp=$(mktemp) && sed "s/<put-your-amf-service-ip-here>/${AMF_IP}/g" templates/5gran-gnb-configmap.yaml > "$tmp" && mv "$tmp" templates/5gran-gnb-configmap.yaml
echo "gNB Config:" && cat templates/5gran-gnb-configmap.yaml
helm install -f values.yaml 5gran ./
echo "Enjoy The 5GRAN!"
