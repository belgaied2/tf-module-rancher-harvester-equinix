#!/bin/bash

#Get Token
BOOTSTRAP_TOKEN=$(curl -sk \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"username": "'$USERNAME'", "password":"'$PASSWORD'"}' \
  https://$HOST/v3-public/localProviders/local?action=login \
  | jq -r .token)
echo {\"token\": \"$BOOTSTRAP_TOKEN\"}