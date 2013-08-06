Backup script using Amazon Glaicer
===================================

Script based on http://matthewlai.ca/download/backup.sh

This version uses Amazon Simle Notification Service to deliver
backup notifications.

Prerequisites
--------------

From the amazon console 

* Create an IAM user with permision to use amazon glaicer and amazon SNS

* Create an SNS topic for notifications. Note the ARN you'll need it when you modify
  the .env file in the described in the installation section

* Create one or more e-mail  subscriptions to receive notifications from the backup system.

Installation
------------

```
 $ easy_install virtualenv # if virtualenv not installed
 $ git clone github.com/../glacier_backup
 $ cd glaicer_backp
 $ cp env.sample .env
 $ vi .env
 # Configure env according to the coments in the file

 $ virtualenv  .
 $ . bin/activate
 $ pip install -r requirements.txt
 $ cd /etc/cron.daily
 $ sudo ln -s /path/to/glaicer_backup .
```

Notes
-----

The script works by using tar to create an incremental backup on the local server. You need at least
as much free disk space on the server as you intend to backup to make the local tar ball.

Incremental files can be removed after they are uploaded to free up space, the script makes no attempt
to do so on it's own.

Also note there is no restore mechanism, it's a manual process and it will take some time to complete. Possibly
days: 

* To do so, you'll first need to start an Amazon Glaicer restore for each incremental backup. 
  This could take up to  4-5 hours to complete. When it dose all e-mails registered per 
  the instructions above will receive an e-mail noting that the archive is ready for downloaded.

* Log on to the server where you wish the archive to be restored, and use a tool like curl to download the archive.

* Untar the archives in order from earliest to newest







