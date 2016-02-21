#!/bin/bash

# make variables for Kiyoon Kim's backup

if [ -z "$KYBACKUP_VAR" ]
then
	KYBACKUP_VAR="1"	# never do this again

	# import settings
	source "`dirname $0`/backup_settings.sh"

	# variables depending on settings
	BACKUP_NUM_END=$((BACKUPNUM_START + MAX_BACKUP - 1))
	BACKUP_LIST=`cat $BACKUP_LIST_FILE | egrep -v "^\s*(#|$)" | awk -F\# '$1!="" { print $1 ;} '` # remove comment
	BACKUP_DIR_WONUM="${BACKUP_ROOT_DIR}/${BACKUPDIR_PREFIX}"
	BACKUP_DIR_WNUM="${BACKUP_DIR_WONUM}${BACKUP_NUM_START}"
	BACKUP_LOG_EXT=".log"
	BACKUP_LOG="${BACKUP_DIR_WNUM}${BACKUP_LOG_EXT}"

	SSH_ADDRESS="${SSH_USER}@${SSH_HOST}"
	if [ ${SSH_ENABLED} -eq 1 ]
	then
		SSH="ssh -p ${SSH_PORT} ${SSH_ADDRESS}"
		SSH_EVAL="${SSH}"
		RSYNC_SSH="--rsh='ssh -p${SSH_PORT}'"
		RSYNC_DEST="${SSH_ADDRESS}:${BACKUP_DIR_WNUM}"
	else
		SSH=""
		SSH_EVAL="eval"
		RSYNC_SSH=""
		RSYNC_DEST="${BACKUP_DIR_WNUM}"
	fi
elif
