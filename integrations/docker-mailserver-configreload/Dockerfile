FROM ubuntu:20.04
LABEL maintainer="aaron@spettl.de"

USER root

RUN apt-get update && apt-get install -y curl python3-pip && rm -rf /var/lib/apt/lists/*

RUN pip3 install j2cli

COPY bin/ /usr/local/bin/
COPY templates/ /usr/local/share/templates/

ENV WEBHOOK_TOKEN=some-random-long-string \
    WEBHOOK_LOG=/var/log/webhook/access.log \
    CONFIG_DIR=/config \
    CONFIG_TMP=/tmp/config \
    MAILADMIN_URL=https://mailadmin.example.com \
    MAILADMIN_API_TOKEN=some-secret-token

CMD ["/usr/local/bin/entrypoint.sh"]
