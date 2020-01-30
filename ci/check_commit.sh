#! /bin/bash

GIT_BRANCH="$1"

echo ""
echo "########################################################################"
echo ""
echo "Checking commit hash"
echo ""
sudo apt-get -y update
sudo apt-get install -y wget git || exit 1
rm -f /tmp/commit-${GIT_BRANCH}.hash
wget https://github.com/aferrero2707/art-appimage/releases/download/nightly/commit-${GIT_BRANCH}.hash -O /tmp/commit-${GIT_BRANCH}.hash

rm -f travis.cancel
if  [ -e /tmp/commit-${GIT_BRANCH}.hash ]; then
	git rev-parse --verify HEAD > /tmp/commit-${GIT_BRANCH}-new.hash
	echo -n "Old ${GIT_BRANCH} hash: "
	cat /tmp/commit-${GIT_BRANCH}.hash
	echo -n "New ${GIT_BRANCH} hash: "
	cat /tmp/commit-${GIT_BRANCH}-new.hash
	diff /tmp/commit-${GIT_BRANCH}-new.hash /tmp/commit-${GIT_BRANCH}.hash
	if [ $? -eq 0 ]; then 
		touch travis.cancel
		echo "No new commit to be processed, exiting"
		exit 0
	fi
fi
cp /tmp/commit-${GIT_BRANCH}-new.hash ./commit-${GIT_BRANCH}.hash

