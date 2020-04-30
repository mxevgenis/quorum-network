#!/bin/bash
cd /home/user/quorum/fromscratch/new-node-1t
java -jar /home/user/tessera.jar -configfile config.json >> tessera.log 2>&1 &
cd /home/user/quorum/fromscratch/
sleep 10
./startnode1.sh
