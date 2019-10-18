FROM python:3.6-alpine3.10
RUN apk update && apk add bash
RUN pip install --no-cache-dir awscli s3cmd
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]