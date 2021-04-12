#!/bin/bash

# backup.sh : backup automatically
# Author : Kiyoon Kim, yoonkr33@gmail.com, sparkware.co.kr
# first version in 2015.10.29

# make sure we're running as root
if (( `id -u` != 0 )); then { echo "Sorry, must be root.  Exiting..."; exit 1; } fi

# import settings and make variables
source "`dirname $0`/var.sh"

# start backup procedure
# remove the oldest backup
echo "remove the oldest backup"

if ($SSH [ -d "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}" ])
then
	$SSH \rm -rf "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}"     
	$SSH \rm -f "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}${BACKUP_LOG_EXT}"
fi

# move number by one
echo "move number by one"
for i in `eval echo "{$((BACKUP_NUM_END-1))..$((BACKUP_NUM_START+1))}"`
do
	if ($SSH [ -d "${BACKUP_DIR_WONUM}$i" ])
	then
		$SSH \mv "${BACKUP_DIR_WONUM}${i}" "${BACKUP_DIR_WONUM}$((i+1))"
		$SSH \mv "${BACKUP_DIR_WONUM}${i}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((i+1))${BACKUP_LOG_EXT}"
	fi
done

# hard link copy the newest backup
echo "hard link copy the newest backup"
if ($SSH [ -d "${BACKUP_DIR_WNUM}" ])
then 
	$SSH \cp -al "${BACKUP_DIR_WNUM}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))"
	$SSH \mv "${BACKUP_DIR_WNUM}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))${BACKUP_LOG_EXT}"
else
	$SSH \mkdir -p ${BACKUP_DIR_WNUM}
fi

# sync
echo "sync"
while read dir
do
	echo "Directory: $dir"
	# ssh command eats STDIN!! To prevent this, connect stdin to /dev/null
	$SSH_EVAL "echo '' >> \"${BACKUP_LOG}\"" < /dev/null
	$SSH_EVAL "echo \"SYNC_DATE `date +%Y%m%d_%H%M%S`\" >> \"${BACKUP_LOG}\"" < /dev/null
	RSYNC="rsync -av --delete --delete-excluded --exclude-from='${EXCLUDE_LIST_FILE}' --relative ${RSYNC_SSH} '${dir}/' '${RSYNC_DEST}'"
	eval "${RSYNC}" | $SSH_EVAL "cat >> '${BACKUP_LOG}'"
done <<< "$BACKUP_LIST"

# touch the date
echo "touch the date"
$SSH \touch "${BACKUP_DIR_WNUM}"

