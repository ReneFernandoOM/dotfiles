#!/bin/bash
# symbolic link to /usr/local//bin/

while true
do
    now=$(date)
    cd ~/Documents/personal/ObsidianVault
    git pull
    git add .
    git commit -am "Vault autocommit: $now on linux"
    git push
    echo "Vault autocommit: $now on linux"
    sleep 600
done
