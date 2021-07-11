#!/bin/bash
set -Eeuo pipefail

function build_config {
  echo "[$(date)] Rebuilding config..."
  /usr/local/bin/build_config.sh
}

function update_config {
  if [[ ! -e $CONFIG_DIR/postfix-aliases.cf ]] ; then
    echo "[$(date)] Creating postfix-aliases.cf..."
    echo "devnull: /dev/null" > $CONFIG_DIR/postfix-aliases.cf
  fi

  for F in postfix-accounts.cf postfix-virtual.cf ; do
    if diff -q $CONFIG_TMP/$F $CONFIG_DIR/$F >/dev/null 2>&1 ; then
      echo "[$(date)] No update needed for $F."
    else
      echo "[$(date)] Updating config file $F..."
      cp -f $CONFIG_TMP/$F $CONFIG_DIR/$F
    fi
  done
}

# initial config update
build_config && update_config || true

# config update on each new webhook access
while IFS= read -r line; do
  build_config && update_config || true
done < <(tail -n0 -f $WEBHOOK_LOG | stdbuf -oL fgrep "$WEBHOOK_TOKEN")
