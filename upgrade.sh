#!/usr/bin/env bash

set -e
_DIR=$(dirname $(realpath "$0"))
cd $_DIR

if ! [ -x "$(command -v udd)" ]; then
deno install -A -f -n udd https://deno.land/x/udd/main.ts
fi

udd src/deps.coffee
