#!/usr/bin/env bash

COUNTER=0
while true
do
  COUNTER=$((COUNTER + 1))
  echo -ne "$COUNTER - " ; curl -s $1 | grep title
  #sleep 0.$[ ( $RANDOM % 9 ) + 1 ]s # sleep 0.1 - 0.9
done
