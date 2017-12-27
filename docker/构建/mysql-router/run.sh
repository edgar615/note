#!/bin/bash

if [ ! -f /.router.ini ]; then
echo "[DEFAULT]" >> router.ini
echo "logging_folder =" >> router.ini
echo "" >> router.ini
echo "[logger]" >> router.ini
echo "level = INFO" >> router.ini
echo "" >> router.ini
echo "[routing:basic_redirect]" >> router.ini
echo "bind_address = 0.0.0.0:7001" >> router.ini
echo "mode = read-only" >> router.ini
echo "destinations = $DEST" >> router.ini
fi

mysqlrouter -c router.ini