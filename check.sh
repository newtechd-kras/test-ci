#!/bin/bash

##git diff --names-only ${BASE_REPO} > target.list
echo "file=$1"
cp $1 target.list

subsidiary=$(awk -F/ '{print $1}' target.list | uniq | wc -l)
env=$(awk -F/ '{print $2}' target.list | uniq | wc -l)

if [ $subsidiary -ne 1 -a $env -ne 1 ]; then
   echo "multi target error"
   exit 1
fi

exit 0
