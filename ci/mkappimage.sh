#! /bin/bash

export APP=ART

(yum update -y && yum install -y git) || exit 1
(mkdir -p /work && cd /work && rm -rf appimage-helper-scripts && \
git clone https://github.com/aferrero2707/appimage-helper-scripts.git) || exit 1
export AI_SCRIPTS_DIR="/sources/ci"
export APPROOT=/work/appimage

DO_BUILD=0
if [ ! -e /work/build.done ]; then DO_BUILD=1; fi
if [ x"$DO_BUILD" = "x1" ]; then
	bash /sources/ci/build-appimage.sh || exit 1
fi
#exit

(mkdir -p "${APPROOT}/scripts" && cp -a $AI_SCRIPTS_DIR/copy-rt.sh "${APPROOT}/scripts" && \
cp -a "/work/appimage-helper-scripts/bundle-gtk2.sh" "${APPROOT}/scripts") || exit 1

bash /sources/ci/package-appimage.sh || exit 1

