#!/bin/sh
#
git=`sh /etc/profile; which git`
## For the App Store, instead use: git describe –abbrev=0 –tags
version=`$git describe --tags --always`
count=`$git rev-list --all |wc -l`
echo "#define GIT_VERSION $version\n#define GIT_COMMIT_COUNT $count" > Resources/InfoPlist.h
