FROM python:3.12-alpine
LABEL maintainer="aaron@spettl.de"

RUN apk --no-cache add bash coreutils curl

RUN pip install jinjanator

COPY bin/ /usr/local/bin/
COPY templates/ /usr/local/share/templates/

ENV WEBHOOK_TOKEN=some-random-long-string
ENV WEBHOOK_LOG=/var/log/webhook/access.log
ENV CONFIG_DIR=/config
ENV CONFIG_TMP=/tmp/config
ENV MAILADMIN_URL=https://mailadmin.example.com
ENV MAILADMIN_API_TOKEN=some-secret-token

CMD ["/usr/local/bin/entrypoint.sh"]
