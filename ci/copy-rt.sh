#! /bin/bash

echo ""
echo "########################################################################"
echo ""
echo "Copy RT folders"
echo ""

# Copy RT folders
mkdir -p "$APPDIR/usr/share"
echo "cp -a \"/usr/local/rt\"/* $APPDIR/usr"
cp -a "/usr/local/rt"/* "$APPDIR/usr" || exit 1
