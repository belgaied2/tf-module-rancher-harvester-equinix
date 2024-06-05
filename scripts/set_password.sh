#!/bin/bash

USERNAME=admin

# Wait for Harvester
echo "-- Wait for Harvester"

while true; do
  status=$(curl --write-out '%{http_code}' -skL --output /dev/null https://$HOST)
  if [ "$status" -eq 200 ]; then
    sleep 10
    break
  fi
  sleep 5
done

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
