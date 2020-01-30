#! /bin/bash

export RT_BRANCH=master
#rm -rf RawTherapee
if [ ! -e RawTherapee ]; then
	git clone https://bitbucket.org/agriggio/art.git --branch $RT_BRANCH --single-branch RawTherapee
        #git clone https://bitbucket.org/aferrero2707/art.git --branch $RT_BRANCH --single-branch RawTherapee
fi
rm -rf RawTherapee/ci
cp -a ci RawTherapee
cd RawTherapee
#docker run -it -v $(pwd):/sources -e "RT_BRANCH=$RT_BRANCH" photoflow/docker-centos7-gtk bash
docker run -it -v $(pwd):/sources -e "RT_BRANCH=$RT_BRANCH" centos:7 bash #/sources/ci/appimage-centos7.sh

