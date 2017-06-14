#!/bin/bash

aws sqs send-message-batch --queue-url https://sqs.ap-northeast-1.amazonaws.com/417025923863/example-queue --entries file://./send-message-batch.json