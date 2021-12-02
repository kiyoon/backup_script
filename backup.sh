#!/bin/bash

# backup.sh : backup automatically
# Author : Kiyoon Kim, yoonkr33@gmail.com, https://kiyoon.kim
# first version in 2015.10.29

# make sure we're running as root
#if (( `id -u` != 0 )); then { echo "Sorry, must be root.  Exiting..."; exit 1; } fi

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
# import settings and make variables
source "$SCRIPT_DIR/var.sh"
# import useful functions
source "$SCRIPT_DIR/bashutils.sh"

# start backup procedure
# remove the oldest backup
echo "Remove the oldest backup"

if ($SSH [ -d "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}" ])
then
	$SSH \rm -rf "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}"     
	$SSH \rm -f "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}${BACKUP_LOG_EXT}"
	$SSH \rm -f "${BACKUP_DIR_WONUM}${BACKUP_NUM_END}${BACKUP_ERRLOG_EXT}"
fi

# move number by one
echo "Move number by one"
for i in `eval echo "{$((BACKUP_NUM_END-1))..$((BACKUP_NUM_START+1))}"`
do
	if ($SSH [ -d "${BACKUP_DIR_WONUM}$i" ])
	then
		$SSH \mv "${BACKUP_DIR_WONUM}${i}" "${BACKUP_DIR_WONUM}$((i+1))"
		$SSH \mv "${BACKUP_DIR_WONUM}${i}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((i+1))${BACKUP_LOG_EXT}"
		$SSH \mv "${BACKUP_DIR_WONUM}${i}${BACKUP_ERRLOG_EXT}" "${BACKUP_DIR_WONUM}$((i+1))${BACKUP_ERRLOG_EXT}"
	fi
done

# hard link copy the newest backup
echo "Hard link copy the newest backup"
if ($SSH [ -d "${BACKUP_DIR_WNUM}" ])
then 
	$SSH \cp -al "${BACKUP_DIR_WNUM}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))"
	$SSH \mv "${BACKUP_DIR_WNUM}${BACKUP_LOG_EXT}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))${BACKUP_LOG_EXT}"
	$SSH \mv "${BACKUP_DIR_WNUM}${BACKUP_ERRLOG_EXT}" "${BACKUP_DIR_WONUM}$((BACKUP_NUM_START+1))${BACKUP_ERRLOG_EXT}"
else
	$SSH \mkdir -p ${BACKUP_DIR_WNUM}
fi

# create logs
$SSH touch "$BACKUP_LOG"
$SSH touch "$BACKUP_ERRLOG"
$SSH chmod "$LOG_PERMISSIONS" "$BACKUP_LOG"
$SSH chmod "$LOG_PERMISSIONS" "$BACKUP_ERRLOG"


# sync
echo "Sync"
num_errors=0
while read dir
do
	echo "Directory: $dir"
	# ssh command eats STDIN!! To prevent this, connect stdin to /dev/null
	$SSH_EVAL "echo '' >> \"${BACKUP_LOG}\"" < /dev/null
	$SSH_EVAL "echo \"SYNC_DATE `date +%Y%m%d_%H%M%S`\" >> \"${BACKUP_LOG}\"" < /dev/null
	RSYNC="rsync -av --delete --delete-excluded --exclude-from='${EXCLUDE_LIST_FILE}' --relative ${RSYNC_SSH} '${dir}/' '${RSYNC_DEST}'"
	#eval "${RSYNC}" | $SSH_EVAL "cat >> '${BACKUP_LOG}'"
	save_stdouterr_print_err "$RSYNC" "$BACKUP_LOG" "$BACKUP_ERRLOG" "$SSH_EVAL"
	if [[ $? -ne 0 ]]
	then
		(( num_errors++ ))
	fi
done <<< "$BACKUP_LIST"

# touch the date
echo "Touch the date"
$SSH \touch "${BACKUP_DIR_WNUM}"

if [[ $num_errors -gt 0 ]]
then
	echo "ERROR: There were $num_errors error(s) on the rsync calls. See $BACKUP_ERRLOG"
	if [[ $TELEGRAM_WHEN_FAIL -ne 0 ]]
	then
		echo "Sending the error log to Telegram"
		errlog_partial=$($SSH_EVAL "cut -c-$TELEGRAM_CHAR_LIMIT '$BACKUP_ERRLOG'")
		/usr/bin/env python3 "$SCRIPT_DIR/telegram_post.py" "$KEYFILE" --title "Backup failed: $LOCAL_HOSTNAME -> $REMOTE_HOSTNAME" --body "$errlog_partial" > /dev/null
	fi
	if [[ $SLACK_WHEN_FAIL -ne 0 ]]
	then
		echo "Sending the error log to Slack"
		errlog_partial=$($SSH_EVAL "cut -c-$SLACK_CHAR_LIMIT '$BACKUP_ERRLOG'")
		/usr/bin/env python3 "$SCRIPT_DIR/slack_post.py" "$KEYFILE" --title "Backup failed: $LOCAL_HOSTNAME -> $REMOTE_HOSTNAME" --body "$errlog_partial" > /dev/null
	fi
else
	if [[ $TELEGRAM_WHEN_SUCCESS -ne 0 ]]
	then
		echo "Sending the backup log to Telegram"
		log_partial=$($SSH_EVAL "cut -c-$TELEGRAM_CHAR_LIMIT '$BACKUP_LOG'")
		/usr/bin/env python3 "$SCRIPT_DIR/telegram_post.py" "$KEYFILE" --title "Backup successful: $LOCAL_HOSTNAME -> $REMOTE_HOSTNAME" --body "$log_partial" > /dev/null
	fi
	if [[ $SLACK_WHEN_SUCCESS -ne 0 ]]
	then
		echo "Sending the backup log to Slack"
		log_partial=$($SSH_EVAL "cut -c-$SLACK_CHAR_LIMIT '$BACKUP_LOG'")
		/usr/bin/env python3 "$SCRIPT_DIR/slack_post.py" "$KEYFILE" --title "Backup successful: $LOCAL_HOSTNAME -> $REMOTE_HOSTNAME" --body "$log_partial" > /dev/null
	fi
fi



