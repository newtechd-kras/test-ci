#!/bin/bash -x

# args
SERVICE=$1
TARGET_LIST=$2

echo "---- update-service.sh"

while read target 
do
  echo "target=${target}"
done < <(cat ${TARGET_LIST})

exit 0
