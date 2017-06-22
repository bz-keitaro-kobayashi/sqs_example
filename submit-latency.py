#!/usr/bin/env python3

import sys
from datetime import datetime
import boto3

queue_url = 'https://sqs.ap-northeast-1.amazonaws.com/417025923863/example-queue'

sqs = boto3.client('sqs')

def send_ping(comment=""):
    start = datetime.utcnow().isoformat()
    sqs.send_message(
            QueueUrl = queue_url,
            MessageBody = ('{"ping":true,"submitted_time":"%sZ","comment":"%s"}' % (start, comment))
            )

print("Initial ping")
send_ping("initial")

print("Warming up queue...")

try:
    warmup_event_count = int(sys.argv[1])
except IndexError:
    warmup_event_count = 10

for i in range(0, warmup_event_count):
    sqs.send_message(
            QueueUrl = queue_url,
            MessageBody = '{"warmup":true}'
        )
    print(".", end='', flush=True)

print("")
print("Ping after %d events" % warmup_event_count)
send_ping("after warmup")
