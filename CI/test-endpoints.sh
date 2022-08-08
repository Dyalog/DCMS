#!/bin/bash
set -e
URL=$1
TESTOUT=/tmp/dcms-test.log
rm -rf ${TESTOUT}
touch ${TESTOUT}
echo "Testout is : ${TESTOUT}"

RES=$(curl -o /dev/null -s -w "%{http_code}\n" "${URL}/persons")
if ! echo $RES | grep 200 > /dev/null; then
    echo "FAILED** Dyalog CMS server returned HTTP status code ${RES}" | tee -a ${TESTOUT}
    exit 1
fi

