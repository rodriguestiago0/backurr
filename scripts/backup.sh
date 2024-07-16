#!/bin/bash

. /app/includes.sh


function upload() {  
    # calculate files

    mapfile -t RCLONE_EXISTING_FILES_LIST < <(rclone ${RCLONE_GLOBAL_FLAG} lsf -R "${RCLONE_REMOTE_X}" --files-only)
    for RCLONE_EXISTING_FILE in "${RCLONE_EXISTING_FILES_LIST[@]}"
    do
       color yellow "file \"${RCLONE_EXISTING_FILE}\""
    done

    # upload
    local FILENAME
    for RCLONE_REMOTE_X in "${RCLONE_REMOTE_LIST[@]}"
    do
        color blue "upload backup file to storage system $(color yellow "[/backup -> ${RCLONE_REMOTE_X}]")"
        rclone ${RCLONE_GLOBAL_FLAG} copy /backup "${RCLONE_REMOTE_X}" --exclude "{$RCLONE_EXISTING_FILES_LIST}"
        if [[ $? != 0 ]]; then
            color red "upload failed"
        fi
    done

}

function clear_history() {
    if [[ "${BACKUP_KEEP_DAYS}" -gt 0 ]]; then
        for RCLONE_REMOTE_X in "${RCLONE_REMOTE_LIST[@]}"
        do
            color blue "delete ${BACKUP_KEEP_DAYS} days ago backup files $(color yellow "[${RCLONE_REMOTE_X}]")"

            mapfile -t RCLONE_DELETE_LIST < <(rclone ${RCLONE_GLOBAL_FLAG} lsf "${RCLONE_REMOTE_X}" --min-age "${BACKUP_KEEP_DAYS}d")

            for RCLONE_DELETE_FILE in "${RCLONE_DELETE_LIST[@]}"
            do
                color yellow "deleting \"${RCLONE_DELETE_FILE}\""

                rclone ${RCLONE_GLOBAL_FLAG} delete "${RCLONE_REMOTE_X}/${RCLONE_DELETE_FILE}"
                if [[ $? != 0 ]]; then
                    color red "delete \"${RCLONE_DELETE_FILE}\" failed"
                fi
            done
        done
    fi
}

color blue "running the backup program at $(date +"%Y-%m-%d %H:%M:%S %Z")"

init_env

check_rclone_connection
upload
clear_history
color none ""
