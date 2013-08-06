Backup script using Amazon Glaicer
===================================

Script based on http://matthewlai.ca/download/backup.sh

This version uses Amazon Simle Notification Service to deliver
backup notifications.

Prerequisites
============

From the amazon console 

* Create an IAM user with permision to use amazon glaicer and amazon SNS

* Create an SNS topic for notifications. Note the ARN you'll need it when you modify
  the .env file in the described in the installation section

* Create one or more e-mail  subscriptions to receive notifications from the backup system.

Installation
============

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
