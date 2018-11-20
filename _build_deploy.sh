#!/bin/sh
TARGET="../moodlenet-web-build" # Where this repository is checked out: https://gitlab.com/moodlenet/clients/web-build

echo "Deploy path: ' + ${TARGET}"

yarn 

yarn build

yarn styleguide:build

cp -r build/* $TARGET

cp -r styleguide $TARGET

cd $TARGET
git add .

msg="front-end build - `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi

# Commit changes
git commit -m "$msg"

# Push to git server
git push origin master -v
