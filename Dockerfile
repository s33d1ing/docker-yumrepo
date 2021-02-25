FROM nginx:stable-alpine

LABEL maintainer="Garrett Dees <garrettdees@gmail.com>"

ENV REPO_PORT=80
ENV REPO_PATH=/var/repo
ENV REPO_DEPTH=2

RUN /sbin/apk add --no-cache --upgrade \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        createrepo_c inotify-tools

COPY ./build/90-create-yum-repository.sh /docker-entrypoint.d/90-create-yum-repository.sh
COPY ./build/default.conf.template /etc/nginx/templates/default.conf.template
COPY ./build/repository-watcher.sh /usr/local/bin/repository-watcher.sh

EXPOSE $REPO_PORT
