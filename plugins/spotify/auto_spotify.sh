#!/usr/bin/env bash

sleep 30

export ACCESS_TOKEN=$(curl -d client_id=$CLIENT_ID -d client_secret=$CLIENT_SECRET -d grant_type=refresh_token -d refresh_token=$REFRESH_TOKEN https://accounts.spotify.com/api/token  | jq -r '.access_token')

n=0
until [ "$n" -ge 5 ]
do
  DEVICE_ID=$(curl -f -X "GET" "https://api.spotify.com/v1/me/player/devices" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" | jq -e -r '.devices[] | select(.name=="balenaSound Spotify b8fd").id')

  if [[ $? == 0 ]]
  then
    export DEVICE_ID
    break
  else
    unset DEVICE_ID
  fi

  n=$((n+1))
  sleep 15
done

sleep 1
curl -X "PUT" "https://api.spotify.com/v1/me/player" --data "{\"device_ids\":[\"$DEVICE_ID\"]}" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN"

sleep 5
curl -X "PUT" "https://api.spotify.com/v1/me/player/play?device_id=$DEVICE_ID" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN"

sleep 1
curl -X "PUT" "https://api.spotify.com/v1/me/player/play?device_id=$DEVICE_ID" -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN"