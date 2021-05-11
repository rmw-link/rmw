#!/usr/bin/env bash

DIR=$(cd "$(dirname "$0")"; pwd)

set -ex
mkdir -p $DIR/wasm
cd $DIR/wasm

name=$(echo $1 | awk -F / '{print $2}')
name=${name/.git/}

if [ ! -d "$name" ] ; then
git submodule add  --depth 1 $1 $name
mkdir -p $DIR/wasm/$name
cd $DIR
mkdir -p src/wasm
cd src/wasm
ln -s ../../wasm/$name/pkg $name
git add $name
git commit -m "add submodule $1"
fi




