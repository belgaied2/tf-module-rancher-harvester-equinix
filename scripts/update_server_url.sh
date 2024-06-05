#/bin/bash
curl -skL -H "Authorization: Bearer $TOKEN" $RANCHER_URL/v3/settings/server-url | jq ".value=\"$RANCHER_URL\"" | curl -skL -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -X PUT --data @- $RANCHER_URL/v3/settings/server-url
echo "Rancher's server-url has been updated to $RANCHER_URL"