#!/bin/bash

USERNAME=admin

#Get Token
echo "-- Get token"
BOOTSTRAP_TOKEN=$(curl -sk \
  --header "Content-Type: application/json" \
  --request POST \
  --data '{"username": "'$USERNAME'", "password":"'$BOOTSTRAP_PASSWORD'"}' \
  https://$HOST/v3-public/localProviders/local?action=login \
  | jq -r .token)

#Set Password
echo "-- Set new password"
curl -sk \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer $BOOTSTRAP_TOKEN" \
  --request POST \
  --data '{"currentPassword": "'$BOOTSTRAP_PASSWORD'", "newPassword": "'$NEW_PASSWORD'"}' \
  https://$HOST/v3/users?action=changepassword
