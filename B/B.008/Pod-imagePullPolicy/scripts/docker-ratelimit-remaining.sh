#!/usr/bin/env bash
# https://docs.docker.com/docker-hub/usage/pulls/

TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" \
        | jq -r .token)

curl -s --head -H "Authorization: Bearer $TOKEN" \
                https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest \
                | grep ratelimit
