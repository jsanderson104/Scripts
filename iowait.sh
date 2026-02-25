#!/bin/bash


## Who or what is waiting for the disk to become available. Termed iowait.
# Refreshes every second.


## You can also use  "iotop -o" to see only processes that are read or write the disk

watch -n 1 "(ps aux | awk '\$8 ~ /D/  { print \$0 }')"
