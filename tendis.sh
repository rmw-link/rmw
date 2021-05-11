#!/usr/bin/env bash

set -ex
DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

if ! [ -x "$(command -v stoml)" ]; then
GO111MODULE=on go get github.com/freshautomations/stoml
asdf reshim
fi

REDIS_PASSWORD=`stoml ~/.rmw/config.toml tendis|awk -F":|@" '{print $3}'`
docker run \
  -d \
  --name rmw-tendis \
  --rm -p 51002:51002 \
  --env REDIS_PASSWORD=$REDIS_PASSWORD \
  --env CLUSTER=no \
  -v /Volumes/rmw.link/tendis:/data1/tendis/51002 \
  tencentdbforkv/tendisplus
