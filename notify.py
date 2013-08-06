#!/usr/bin/env python

import sys
import os
import boto

conn = boto.connect_sns()
conn.publish(
  os.environ['SNS_TOPIC'],
  sys.stdin.read()
)
