#!/bin/bash

if which docker-compose 2>/dev/null ;then
    COMPOSE=$(which docker-compose)
else
    COMPOSE="$(which docker) compose"
fi

## Populate env file
rm ${PWD}/env
echo YOUTUBE="http://localhost:8088/" >> ${PWD}/env
echo APP_DIR=/app >> ${PWD}/env
echo LX="DCMS.Setup 0 ⋄ DCMS.Run 0 ⋄ Admin.RunTests 0" >> ${PWD}/env
echo RIDE_INIT=SERVE:*:4502 >> ${PWD}/env
echo SQL_SERVER=db >> ${PWD}/env
echo SQL_DATABASE=dyalog_cms >> ${PWD}/env
echo SQL_USER=dcms >> ${PWD}/env
echo SQL_PASSWORD=apl >> ${PWD}/env
echo SQL_PORT=3306 >> ${PWD}/env
echo MYSQL_SERVER=db >> ${PWD}/env
echo MYSQL_DATABASE=dyalog_cms >> ${PWD}/env
echo MYSQL_USER=dcms >> ${PWD}/env
echo MYSQL_PASSWORD=apl >> ${PWD}/env
echo MYSQL_PORT=3306 >> ${PWD}/env
echo SECRETS=/app/secrets/secrets.json5 >> ${PWD}/env
echo MYSQL_RANDOM_ROOT_PASSWORD=1 >> ${PWD}/env

echo COMPOSE IS: $COMPOSE
echo "Use docker inspect to get the IP of the running container"

$COMPOSE pull
$COMPOSE -f docker-compose.yml up db web --force-recreate
