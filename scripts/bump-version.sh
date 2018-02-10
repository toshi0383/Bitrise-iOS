#!/bin/bash
INFOPLIST=BitriseClient/Info.plist
PLBUDDY=/usr/libexec/PlistBuddy

VERSION=${1:?}
CURRENT=${2:-`$PLBUDDY -c 'Print CFBundleShortVersionString' "$INFOPLIST"`}

sed -i "" -e "s/master/${VERSION}/" CHANGELOG.md
$PLBUDDY -c "Set CFBundleShortVersionString $VERSION" "$INFOPLIST"
