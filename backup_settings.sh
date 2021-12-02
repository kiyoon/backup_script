#!/bin/bash

# settings file of "backup.sh" by Kiyoon Kim

## directory names are "backup_0" to "backup_6" if BACKUP_NUM_START=0 and MAX_BACKUP=7
BACKUP_NUM_START=0	
MAX_BACKUP=7

## backup list 
BACKUP_LIST_FILE="$SCRIPT_DIR/backup_list"
EXCLUDE_LIST_FILE="$SCRIPT_DIR/backup_exclude"
BACKUP_ROOT_DIR="/root/backup"
BACKUPDIR_PREFIX="backup_"
LOG_PERMISSIONS=600		# 600: Don't allow normal users to read logs.

## ssh
# you should register key for ssh with ssh-keygen. Otherwise, password will be required.
SSH_ENABLED=0		# SSH_ENABLED=1 if you want to use SSH
SSH_USER="root"
SSH_HOST="192.168.0.2"
SSH_PORT=22


## Sending results to chat bots

KEYFILE="$SCRIPT_DIR/key.ini"

# Telegram
TELEGRAM_WHEN_SUCCESS=0
TELEGRAM_WHEN_FAIL=0		# setting it to 1 enables it.
TELEGRAM_CHAR_LIMIT=3900

# Slack
SLACK_WHEN_SUCCESS=0
SLACK_WHEN_FAIL=1
SLACK_CHAR_LIMIT=3800
