#!/bin/sh

SCRIPT_NAME=$(basename $0)

function create_repo_metadata() {
    echo >&3 "${SCRIPT_NAME}: Creating repository metadata (maxdepth ${REPO_DEPTH})"

    /usr/bin/find ${REPO_PATH} -type d -maxdepth ${REPO_DEPTH} -mindepth ${REPO_DEPTH} |
        while read DIR; do
            /usr/bin/createrepo_c ${DIR}

            if [ -d "${DIR}/.repodata" ]; then
                echo >&3 "${SCRIPT_NAME}: Manually renaming ${DIR}/.repodata -> ${DIR}/repodata"

                /bin/mv ${DIR}/.repodata ${DIR}/repodata
            fi

            /bin/rm -rf ${DIR}/repodata.old.*
        done
}

function watch_repo_changes() {
    echo >&3 "${SCRIPT_NAME}: Watching ${REPO_PATH} for recursively changes"

    /usr/bin/inotifywait -m -r -e create -e delete -e delete_self --excludei "(repodata|.*xml)" ${REPO_PATH} |
        while true; do
            COUNT=0

            while read -t 10 PATH ACTION FILE; do
                echo >&3 "${SCRIPT_NAME}: Detected change to ${PATH}${FILE} (action ${ACTION})"

                COUNT=$((COUNT+1))
            done

            if [ $COUNT -gt 0 ]; then
                create_repo_metadata
            fi
        done
}

create_repo_metadata
watch_repo_changes

exit 0
