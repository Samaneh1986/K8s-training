export RANCHER_TOKEN_KEY=$(cat ./rancher-token.txt )
  
export CLUSTER_ID='c-xxx'
export API_URL='https://rancher.mydomain.com/v3/clusters/'$CLUSTER_ID'?action=generateKubeconfig'
export KUBE_CONFIG_PATH="~/.kube/config"

curl -u "${RANCHER_TOKEN_KEY}" \
-X POST \
-H 'Accept: application/json' \
-H 'Content-Type: application/json' \
"${API_URL}" | jq -r '.config' > config

cp config ~/.kube/
rm config

#check cluster, you need the kubectl installed
#echo "****** CLUSTER INFORMATION  ******"
#kubectl cluster-info
#kubectl get node
