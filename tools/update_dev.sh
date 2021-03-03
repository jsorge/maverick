#!/usr/bin/env bash

if [ -d "_dev" ]; then
  rm -r _dev
fi

mkdir tmp
cd tmp

archive=dev.zip
curl -L -o $archive https://github.com/jsorge/jsorge.net/archive/leaf-4.zip
unzip $archive
folder=$(ls -d */ | head -1)
cd ..

mv tmp/$folder _dev/
rm -r tmp