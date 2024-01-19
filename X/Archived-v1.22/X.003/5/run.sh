#!/usr/bin/env bash

sshpass -p vagrant ssh -o StrictHostKeyChecking=no root@wk8s-m 'mkdir /etc/kubernetes/admission'
sshpass -p vagrant scp -o StrictHostKeyChecking=no * root@wk8s-m:/etc/kubernetes/admission 
