#!/bin/bash

USERNAME=admin

#Get Token
echo "-- Get token"
TOKEN=$(curl -sk \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"username": "'$USERNAME'", "password":"'$PASSWORD'"}' \
  https://$HOST/v3-public/localProviders/local?action=login \
  | jq -r .token)


# Get Kubeconfig
echo "-- Get Kubeconfig"
KUBECONFIG=$(curl -sk \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $TOKEN" \
  --request POST \
  https://$HOST/v3/clusters/local?action=generateKubeconfig \
  | jq -r .config)

echo "$KUBECONFIG" > ../../$HOST.yaml
