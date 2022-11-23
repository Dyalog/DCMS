#!/bin/bash
# DCMS check_version.sh
set -e

# A local or jenkins builder will call this script from the root of the checked out git repo
# Another build mechanism might copy files to another directory before modifying them
if [ $# -eq 0 ];
# $D is root directory of files to be injected, assuming they have the same relative structure as the original repository
    then
        D=$PWD   # Assume we are in project root calling "./CI/inject_version.sh"
    else
        D=$1     # If argument given, that is new root dir of file to be injected. 
fi

REPO_DIR="$(dirname $0)/../"

VERSION_SOURCE="${D}/src/Version.aplf"

FILES="$VERSION_SOURCE"
MISSING=""

for FILE in $FILES
do
    if [ ! -f $FILE ]; then
        echo "File not found: $FILE";
        MISSING="$MISSING $FILE";
    fi
done


V0=`git show HEAD~1:src/Version.aplf | grep -o "^\s*version\s\?←'[0-9]\+\.[0-9]\+\.[0-9]\+'" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+"`
V1=`cat src/Version.aplf | grep -o "^\s*version\s\?←'[0-9]\+\.[0-9]\+\.[0-9]\+'" | grep -o "[0-9]\+\.[0-9]\+\.[0-9]\+"`

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

echo $V0
echo $V1

if [ $(version $V1) -le $(version $V0) ]; then
    echo "Please increment version number. Current version $V1"
    exit 1
fi

major_minor=`echo ${raw_version} | grep -o "[0-9]\+\.[0-9]\+"`
special=""
if n=$(echo ${raw_version} | grep -wic "\-\w+$"); then
    special=`echo ${raw_version} | grep -o "\-\w\+$"`
fi

full_version=${major_minor}.${patch}${special}

echo ${full_version}

