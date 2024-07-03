#!/bin/bash
set -e
URL=$1
TESTOUT=/tmp/dcms-test.log
rm -rf ${TESTOUT}
touch ${TESTOUT}
echo "Testout is : ${TESTOUT}"

RES=$(curl -o /dev/null -s -w "%{http_code}\n" "http://${URL}:8080/person")
if ! [ $RES -eq "200" ]; then
    echo "FAILED** Dyalog CMS server returned HTTP status code ${RES}" | tee -a ${TESTOUT}
    exit 1
else
    echo "PASSED $(basename $0)"
fi

