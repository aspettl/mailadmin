#!/bin/bash
set -Eeuo pipefail

if ! which curl >/dev/null
then
  echo "Make sure you installed curl: apt install curl"
  exit 1
fi

if ! which jinjanate >/dev/null
then
  echo "Make sure you installed jinjanate: pip install jinjanator"
  exit 1
fi

JSON=$(curl --silent --fail --header "Authorization: Bearer $MAILADMIN_API_TOKEN" --write-out "%{stderr}[$(date)] Getting JSON data, HTTP status code: %{http_code}\n%{stdout}\n" $MAILADMIN_URL/api/v1/export.json)

echo "$JSON" | jinjanate --format=json /usr/local/share/templates/postfix-accounts.cf > $CONFIG_TMP/postfix-accounts.cf
echo "$JSON" | jinjanate --format=json /usr/local/share/templates/postfix-virtual.cf > $CONFIG_TMP/postfix-virtual.cf
