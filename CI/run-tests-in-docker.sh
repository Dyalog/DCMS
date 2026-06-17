#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

if which docker-compose 2>/dev/null ;then
    COMPOSE=$(which docker-compose)
else
    COMPOSE="$(which docker) compose"
fi

## Populate env file
rm ${REPO_DIR}/env
echo YOUTUBE=http://localhost:8088/ >> ${REPO_DIR}/env
echo APP_DIR=/app >> ${REPO_DIR}/env
echo CONFIGFILE=/app/CI/test.dcfg >> ${REPO_DIR}/env
echo RIDE_INIT=SERVE:*:4502 >> ${REPO_DIR}/env
echo SQL_SERVER=db >> ${REPO_DIR}/env
echo SQL_DATABASE=dyalog_cms >> ${REPO_DIR}/env
echo SQL_USER=dcms >> ${REPO_DIR}/env
echo SQL_PASSWORD=apl >> ${REPO_DIR}/env
echo SQL_PORT=3306 >> ${REPO_DIR}/env
echo MYSQL_SERVER=db >> ${REPO_DIR}/env
echo MYSQL_DATABASE=dyalog_cms >> ${REPO_DIR}/env
echo MYSQL_USER=dcms >> ${REPO_DIR}/env
echo MYSQL_PASSWORD=apl >> ${REPO_DIR}/env
echo MYSQL_PORT=3306 >> ${REPO_DIR}/env
echo SECRETS=/app/secrets/secrets.json5 >> ${REPO_DIR}/env
echo MYSQL_RANDOM_ROOT_PASSWORD=1 >> ${REPO_DIR}/env
echo HOME=/data >> ${REPO_DIR}/env

echo COMPOSE IS: $COMPOSE
echo "Use docker inspect to get the IP of the running container"

export PROJECT_DIR=$PWD

sudo -E $COMPOSE -f ${REPO_DIR}/docker-compose.yml pull
sudo -E $COMPOSE -f ${REPO_DIR}/docker-compose.yml up install
sudo -E $COMPOSE -f ${REPO_DIR}/docker-compose.yml up db web --force-recreate --abort-on-container-exit
