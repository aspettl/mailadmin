FROM python:3-alpine
LABEL maintainer="aaron@spettl.de"

RUN apk --no-cache add bash coreutils curl

RUN pip install jinjanator

COPY bin/ /usr/local/bin/
COPY templates/ /usr/local/share/templates/

ENV WEBHOOK_TOKEN=some-random-long-string \
    WEBHOOK_LOG=/var/log/webhook/access.log \
    CONFIG_DIR=/config \
    CONFIG_TMP=/tmp/config \
    MAILADMIN_URL=https://mailadmin.example.com \
    MAILADMIN_API_TOKEN=some-secret-token

CMD ["/usr/local/bin/entrypoint.sh"]
