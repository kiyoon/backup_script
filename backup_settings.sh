#!/bin/bash

# settings file of "backup.sh" by Kiyoon Kim

# directory names are "backup_0" to "backup_6" if BACKUP_NUM_START=0 and MAX_BACKUP=7
BACKUP_NUM_START=0	
MAX_BACKUP=7

# backup list 
BACKUP_LIST_FILE="/home/sparkware/backup_script/backup_list"
EXCLUDE_LIST_FILE="/home/sparkware/backup_script/backup_exclude"
BACKUP_ROOT_DIR="/home/sparkware/backup_script/backup"
BACKUPDIR_PREFIX="backup_"
