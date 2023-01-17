#!/bin/bash

set -euxo pipefail

date=$(date '+%Y%m%d%H%M%S')

# args
SERVICE=$1
BRANCH_NAME=$2
TARGET_LIST=$3
GIT_USER="newtechd-kras"
# GIT_TOKEN

echo "---- update-service.sh TARGET_LIST=${TARGET_LIST}"

REPO_BASE="newtechd-kras"
REPO_NAME=${SERVICE}
PR_TITLE="add-release-${SERVICE}"
PR_BASE="main"

echo $GIT_TOKEN
WORK_DIR=$(pwd)

cd ~

# clone git
git config --global user.email "kras@newtechd.com"
git config --global user.name "Yasunari Inoue"
git clone https://$GIT_USER:$GIT_TOKEN@github.com/$REPO_BASE/$REPO_NAME.git

# create branch
cd ${REPO_NAME}
git checkout -b $BRANCH_NAME

# target loop
while read target 
do
  echo "target=${target}"
  TARGET_DIR=$(dirname ${target})
  mkdir -p ${TARGET_DIR}
  cp ${WORK_DIR}/${target} ${TARGET_DIR}
done < <(cat ${TARGET_LIST})

git add .
git commit -m "add release ${SERVICE} ${date}"
git push origin ${BRANCH_NAME}

curl \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${GIT_TOKEN}" \
  "https://api.github.com/repos/${REPO_BASE}/${REPO_NAME}/pulls?state=open&sort=updated&direction=desc" > pulls.json
pulls_count=$(cat pulls.json | jq .[].head.ref | grep ${BRANCH_NAME} | wc -l)
if [ ${pulls_count} -eq 0 ]; then
    curl -X POST -u "$GIT_USER:$GIT_TOKEN" \
        "https://api.github.com/repos/${REPO_BASE}/${REPO_NAME}/pulls" \
        -H "Accept: application/vnd.github.v3+json" \
        -d "{\"title\": \"${PR_TITLE}\", \"head\": \"${BRANCH_NAME}\", \"base\": \"${PR_BASE}\"}" > response.json
    cat response.json
    URL=$(jq -r .url response.json)
else
    URL=$(cat pulls.json | jq .[0].url)
fi
echo ${URL}
#curl -u "$GIT_USER:$GIT_TOKEN" -X PUT -H "Accept: application/vnd.github.v3+json" $URL/merge
#curl -s -X DELETE -u "$GIT_USER:$GIT_TOKEN" https://api.github.com/repos/${REPO_BASE}/${REPO_NAME}/git/refs/heads/${BRANCH_NAME}

cd ${WORK_DIR}
rm -rf ~/${REPO_NAME}
exit 0
