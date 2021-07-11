#!/bin/bash
set -Eeuo pipefail

if ! which curl >/dev/null
then
  echo "Make sure you installed curl: apt install curl"
  exit 1
fi

if ! which j2 >/dev/null
then
  echo "Make sure you installed j2: pip install j2cli"
  exit 1
fi

JSON=$(curl --silent --fail --header "Authorization: Bearer $MAILADMIN_API_TOKEN" --write-out "%{stderr}[$(date)] Getting JSON data, HTTP status code: %{http_code}\n%{stdout}\n" $MAILADMIN_URL/api/v1/export.json)

echo "$JSON" | j2 --format=json /usr/local/share/templates/postfix-accounts.cf > $CONFIG_TMP/postfix-accounts.cf
echo "$JSON" | j2 --format=json /usr/local/share/templates/postfix-virtual.cf > $CONFIG_TMP/postfix-virtual.cf
