#!/bin/bash
docker run -it --rm \
-e TEST_FILE=/tmp/dcms-test-results \
-e APP_DIR=/app \
-e SERVICE_URL=localhost \
-e SERVICE_PORT=8080 \
-e CONFIGFILE=/app/CI/testing.dcfg \
-v $PWD:/app \
dyalog/techpreview:latest
