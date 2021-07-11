#!/bin/bash
set -Eeuo pipefail

mkdir -p $CONFIG_DIR $CONFIG_TMP

STARTUP_SLEEP=${STARTUP_SLEEP:-30}
echo "[$(date)] Start up - sleeping for $STARTUP_SLEEP seconds..."
sleep $STARTUP_SLEEP

source /usr/local/bin/monitor_webhook.sh
