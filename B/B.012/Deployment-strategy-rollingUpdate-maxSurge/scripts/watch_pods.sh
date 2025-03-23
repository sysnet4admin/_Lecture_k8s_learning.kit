#!/usr/bin/env bash

watch 'echo "Total: $(kubectl get po | sed 1d | wc -l)\n"; kubectl get po'
