#!/bin/sh

SCRIPT_NAME=$(basename $0)

NGINX_CONFIG="/etc/nginx/conf.d/default.conf"

function create_repo_metadata() {
    echo >&3 "${SCRIPT_NAME}: Creating repository metadata (maxdepth ${REPO_DEPTH})"
    echo >&3 "${SCRIPT_NAME}: Beware: This may take a while with a large repository!"
    echo >&3 "${SCRIPT_NAME}: Notice: NGINX will be unavailable during this process!"

    /bin/sed -i "s/# return 503;/return 503;/g" ${NGINX_CONFIG}
    /usr/sbin/nginx -s reload

    /usr/bin/find ${REPO_PATH} -maxdepth ${REPO_DEPTH} -mindepth ${REPO_DEPTH} -type d |
        while read DIR; do
            echo >&3 "${SCRIPT_NAME}: Running createrepo on ${DIR}"

            /usr/bin/createrepo_c --update ${DIR}

            if [ -d "${DIR}/.repodata" ]; then
                echo >&3 "${SCRIPT_NAME}: Manually renaming ${DIR}/.repodata -> ${DIR}/repodata"

                /bin/mv ${DIR}/.repodata ${DIR}/repodata
            fi

            /bin/rm -rf ${DIR}/repodata.old.*
        done

    /bin/sed -i "s/return 503;/# return 503;/g" ${NGINX_CONFIG}
    /usr/sbin/nginx -s reload
}

function watch_repo_changes() {
    echo >&3 "${SCRIPT_NAME}: Watching ${REPO_PATH} for recursively changes"
    echo >&3 "${SCRIPT_NAME}: Notice: This does not work with the WSL 2 based engine!"

    /usr/bin/inotifywait -m -r -e "create" -e "delete" -e "delete_self" --excludei "(repodata|\.xml)" ${REPO_PATH} |
        while true; do
            COUNT=0
            SLEEP=10

            while [ ${SLEEP} -gt 0 ]; do
                while read -t 1 PATH ACTION FILE; do
                    echo >&3 "${SCRIPT_NAME}: Detected change to ${PATH}${FILE} (action ${ACTION})"

                    COUNT=$((COUNT+1))
                    SLEEP=$((SLEEP+1))
                done

                SLEEP=$((SLEEP-1))
            done

            if [ ${COUNT} -gt 0 ]; then
                create_repo_metadata
            fi
        done
}

create_repo_metadata
watch_repo_changes

exit 0
