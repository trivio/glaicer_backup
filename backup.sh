#!/bin/bash

# Copyright (C) 2013 Matthew Lai
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

####### BEGIN CONFIGURABLE PARAMETERS #######


# Change config by editing the file .env in the same dir as this
# script, see env.sample for examples
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -f "$DIR/.env" ]] && . "$DIR/.env"

mkdir -p $BACKUP_DIR

# re export SNS_TOPIC for the notify script
export SNS_TOPIC
DATE_STR=`date -u +%Y%m%d%H%M%S`

typeset -i INCREMENT_COUNT
INCREMENT_COUNT=0

LOGFILE="$BACKUP_DIR/log.txt"

exec >> "$LOGFILE" 2>&1

date

if [ ! -d "$DATA_DIR" ]; then
     echo "Data directory does not exist or is not a directory"
     exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
     echo "Backup directory does not exist or is not a directory"
     exit 2
fi

if [ -e "$BACKUP_DIR/lock" ]; then
     echo "Instance terminated. Another instance maybe running, if note remove file $BACKUP_DIR/lock"
     
     # we have to report this right away because otherwise if an instance hangs, the user may never notice
     cat "$LOGFILE" | ./notify.py 
     
     exit 3
fi

touch "$BACKUP_DIR/lock"

if [ ! -f "$BACKUP_DIR/archive.snar" ]; then
     echo "snar file not found, creating level 0 dump"
     rm -f "$BACKUP_DIR/inc_count.txt"
fi

if [ -f "$BACKUP_DIR/inc_count.txt" ];  then
     INCREMENT_COUNT=`cat "$BACKUP_DIR/inc_count.txt"`
fi

echo `expr $INCREMENT_COUNT + 1` > "$BACKUP_DIR/inc_count.txt"

TAR_FILENAME="archive".`date -u +%Y%m%d%H%M%S`.$INCREMENT_COUNT.tar.gz
TAR_PATH="$BACKUP_DIR/$TAR_FILENAME"

echo "Creating $TAR_FILENAME"

tar --create -z --listed-incremental="$BACKUP_DIR/archive.snar" -f "$TAR_PATH" "$DATA_DIR"
tar --list -z --incremental --verbose --verbose -f "$TAR_PATH"

echo "`ls -lah "$TAR_PATH" | awk '{ print $5 }'` bytes"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY

$GLACIER_CLI upload --region $AWS_REGION $AWS_VAULT_NAME $TAR_PATH

echo ""

if [ `expr $INCREMENT_COUNT % $EMAIL_LOG_PERIOD` -eq 0 ]; then
     cat "$LOGFILE" | ./notify.py 
     rm "$LOGFILE"
fi

rm "$BACKUP_DIR/lock"

