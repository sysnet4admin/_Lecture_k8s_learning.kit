#!/usr/bin/env bash

while true
do
  COUNTER=$((COUNTER + 1))
  echo -ne "$COUNTER - " ; curl $1 
  sleep 0.1 
done
