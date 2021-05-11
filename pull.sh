#!/usr/bin/env bash

set -e
_DIR=$(dirname $(realpath "$0"))
cd $_DIR

git add -u && git commit -m. && git pull

git submodule update --remote

