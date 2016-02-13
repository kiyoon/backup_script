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

# start backup procedure
# remove the oldest backup

if [ -d "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}" ]
then
	\rm -rf "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}"     
fi

# move number by one
for i in `eval echo "{$((BACKUP_NUM_END-1))..$((BACKUP_NUM_START+1))}"`
do
	if [ -d "${BACKUP_DIR_WONUM}$i" ]
	then
		\mv "${BACKUP_DIR_WONUM}$i" "${BACKUP_DIR_WONUM}$((i+1))"
	fi
done

# hard link copy the newest backup
if [ -d ${BACKUP_DIR_WNUM} ]
then 
	\cp -al "${BACKUP_DIR_WNUM}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))"
else
	\mkdir -p ${BACKUP_DIR_WNUM}
fi

# sync
echo "$BACKUP_LIST" | while read dir
do
	if [ ${SSH} -eq 1 ]
	then
		rsync -av --delete --delete-excluded --exclude-from=${EXCLUDE_LIST_FILE} --relative "${dir}/" --rsh="ssh -p${SSH_PORT}" "${SSH_USER}@${SSH_HOST}:${BACKUP_DIR_WNUM}"
	else
		rsync -av --delete --delete-excluded --exclude-from=${EXCLUDE_LIST_FILE} --relative "${dir}/" "${BACKUP_DIR_WNUM}"
	fi
done

# touch the date
touch ${BACKUP_DIR_WNUM}
