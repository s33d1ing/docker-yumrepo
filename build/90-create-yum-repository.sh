#!/bin/sh

SCRIPT_NAME=$(basename $0)

HOST_IP=$(ip route | awk '/default/ {print $3}')
CONTAINER_IP=$(ip addr show eth0 | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}')

REPOSITORY_WATCHER="/usr/local/bin/repository-watcher.sh"

function create_repo_dir() {
    echo >&3 "${SCRIPT_NAME}: Setting permissions and ownership of ${REPO_PATH}"

    /bin/mkdir -p ${REPO_PATH}
    /bin/chmod -R 755 ${REPO_PATH}
    /bin/chown -R nginx:nginx ${REPO_PATH}
}

function start_repo_watcher() {
    echo >&3 "${SCRIPT_NAME}: Launching ${REPOSITORY_WATCHER}"

    /bin/sh ${REPOSITORY_WATCHER} &
}

create_repo_dir
start_repo_watcher

exit 0
