#!/bin/sh

set -e

SCRIPT_NAME=$(basename $0)

function create_repo_metadata() {
    echo >&3 "$SCRIPT_NAME: Creating repository metadata (maxdepth ${REPO_DEPTH})"

    /usr/bin/find ${REPO_PATH} -type d -maxdepth ${REPO_DEPTH} -mindepth ${REPO_DEPTH} -exec /usr/bin/createrepo_c {} \;
}

function watch_repo_changes() {
    echo >&3 "$SCRIPT_NAME: Watching ${REPO_PATH} for recursively changes"

    /usr/bin/inotifywait -m -r -e create -e delete -e delete_self --excludei "(repodata|.*xml)" ${REPO_PATH} |
    while read PATH ACTION FILE; do
        echo >&3 "$SCRIPT_NAME: Detected change to ${PATH}${FILE} (action ${ACTION})"

        create_repo_metadata
    done
}

create_repo_metadata
watch_repo_changes

exit 0
