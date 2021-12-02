# backup_script

**Local & remote (SSH) incremental backup for your servers!**

## Original Author : Kiyoon Kim (yoonkr33@gmail.com)

Backup files(directories) listed at `backup_list` file, excluding files listed at `backup_exclude` file.
`backup_exclude` has higher priority than `backup_list` file.

Configurations are at `backup_settings.sh`. After setting the configuration file, executing `backup.sh` will backup your system.

Directory structures are preserved, after the root backup directory. When all files are backed up, it will touch the root backup directory so that it will store the backup date.

## Crontab Settings
You can run the backup script periodically using crontab. For example,  
`10 3 */3 * * /path/to/backup.sh`  
will run backup.sh every 3 days at 3:10 AM.


## Tips on Mounting

The backup partition should be mounted under `/root` so none of the other users can access (and modify) the backup. If you want to expose the backup to normal users, consider binding the mount directory with read-only attribute. You need a recent kernel to do so, and Ubuntu 18.04 and 20.04 seem to work well.

```bash
mount --bind -o ro /root/backup /disk/backup
```

Or, in `/etc/fstab`,

```
/root/backup /disk/backup none bind,ro 0 0
```

## Telegram and Slack Bot Reporting
You can report the success or error log to Telegram and/or Slack!  
Make `key.ini` similarily to `key.ini.template`. Enable reporting on `backup_settings.sh`.  
That's it!
