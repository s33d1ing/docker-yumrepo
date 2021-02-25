FROM nginx:stable-alpine

LABEL maintainer="Garrett Dees <garrettdees@gmail.com>"

ENV REPO_PORT=80
ENV REPO_PATH=/var/repo
ENV REPO_DEPTH=2

COPY build/packages /tmp/apk

RUN apk add --no-cache --no-network --repositories-file=/dev/null /tmp/apk/*

COPY build/90-create-yum-repository.sh /docker-entrypoint.d/90-create-yum-repository.sh
COPY build/default.conf.template /etc/nginx/templates/default.conf.template
COPY build/repository-watcher.sh /usr/local/bin/repository-watcher.sh

RUN /usr/bin/dos2unix /docker-entrypoint.d/90-create-yum-repository.sh
RUN /usr/bin/dos2unix /etc/nginx/templates/default.conf.template
RUN /usr/bin/dos2unix /usr/local/bin/repository-watcher.sh

EXPOSE $REPO_PORT
