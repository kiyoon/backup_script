# backup_script

## Original Author : Kiyoon Kim (yoonkr33@gmail.com)

Backup files(directories) listed at "backup_list" file, excluding files listed at "backup_exclude" file.
"backup_exclude" has higher priority than "backup_list" file.

Configurations are at "backup_settings.sh". After setting the configuration file, executing "backup.sh" will backup your system. Old backups will be deleted, and you can set how much times you will store the backups.

Directory structures are preserved, after the root backup directory. When all files are backuped, it will touch the root backup directory so that it will store the backup date.