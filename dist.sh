#!/usr/bin/env bash

_DIR=$(cd "$(dirname "$0")"; pwd)
cd $_DIR


version="./version.txt"
next=$(cat $version | awk -F. -v OFS=. '{$NF++;print}')
echo $next > $version
echo $next

sed -i "s/@[0-9]\+.[0-9]\+.[0-9]\+\//@$next\//g" readme.make.md
git add -u
git commit -m "."
git tag $next
git push --tag

