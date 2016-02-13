#!/bin/bash

# backup.sh : backup automatically
# Author : Kiyoon Kim, yoonkr33@gmail.com, sparkware.co.kr
# first version in 2015.10.29

# make sure we're running as root
if (( `id -u` != 0 )); then { echo "Sorry, must be root.  Exiting..."; exit 1; } fi

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

# start backup procedure
# remove the oldest backup

if ($SSH [ -d "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}" ])
then
	$SSH \rm -rf "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}"     
	$SSH \rm -f "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}${BACKUP_LOG_EXT}"
fi

# move number by one
for i in `eval echo "{$((BACKUP_NUM_END-1))..$((BACKUP_NUM_START+1))}"`
do
	if ($SSH [ -d "${BACKUP_DIR_WONUM}$i" ])
	then
		$SSH \mv "${BACKUP_DIR_WONUM}${i}" "${BACKUP_DIR_WONUM}$((i+1))"
		$SSH \mv "${BACKUP_DIR_WONUM}${i}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((i+1))${BACKUP_LOG_EXT}"
	fi
done

# hard link copy the newest backup
if ($SSH [ -d "${BACKUP_DIR_WNUM}" ])
then 
	$SSH \cp -al "${BACKUP_DIR_WNUM}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))"
	$SSH \mv "${BACKUP_DIR_WNUM}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))${BACKUP_LOG_EXT}"
else
	$SSH \mkdir -p ${BACKUP_DIR_WNUM}
fi

# sync
echo "$BACKUP_LIST" | while read dir
do
	$SSH_EVAL "echo '' >> \"${BACKUP_LOG}\""
	$SSH_EVAL "echo \"SYNC_DATE `date +%Y%m%d_%H%M%S`\" >> \"${BACKUP_LOG}\""
	RSYNC="rsync -av --delete --delete-excluded --exclude-from='${EXCLUDE_LIST_FILE}' --relative ${RSYNC_SSH} '${dir}/' '${RSYNC_DEST}'"
	rsync_out=$(eval "${RSYNC}")
	$SSH_EVAL "echo \"${rsync_out}\" >> \"${BACKUP_LOG}\""
done

# touch the date
$SSH \touch "${BACKUP_DIR_WNUM}"

