GitHub address of mailadmin project: https://github.com/aspettl/mailadmin

# docker-mailserver integration

This is a simple way to export mailadmin data and build required config files
for https://github.com/docker-mailserver/docker-mailserver.

## Concept

This container should be running on the same host as docker-mailserver - for
mailadmin this is (intentionally) not required. Besides docker-mailserver, there
should also be some webserver running and its log file needs to be mounted into
this container.

The approach is simple: there is some magic webhook token and we check the
existing webserver log file for its presence. When the token is found, the
docker-mailserver config (`postfix-accounts.cf` and `postfix-virtual.cf`) is
regenerated. On startup, the config is always (re)generated.
Note that docker-mailserver will automatically reload when the files are changed.

Tip: It is recommended to have a cron job regularly triggering the webhook, e.g.
every hour. This is helpful as it is easy to forget to hit "Reload configuration"
in mailadmin.

## Configuration requirements in docker-mailserver

The `postfix-aliases.cf` file needs a line `devnull: /dev/null`. This file is
only auto-generated if it does not exist yet.

Set `ENABLE_QUOTAS=0` in your configuration, otherwise starting with version 10.3.0
local mail accounts will be listed twice in `/etc/dovecot/userdb`, which produces
errors in the logs.
