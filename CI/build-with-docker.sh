#!/bin/bash

if which docker-compose 2>/dev/null ;then
    COMPOSE=$(which docker-compose)
else
    COMPOSE="$(which docker) compose"
fi

## Populate env file
rm ${PWD}/env
echo LOAD=/app/CI/Build.aplf >> ${PWD}/env
echo APP_DIR=/app >> ${PWD}/env

$COMPOSE pull
$COMPOSE -f docker-compose.yml up build
