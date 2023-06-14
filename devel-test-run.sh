#! /bin/sh
set -e

NAME='codehost-devel'
docker build --tag $NAME .
docker run --name=$NAME --privileged --publish 7837:22 --publish 7838:7838 --env="GITHUB_USER=SamuLumio" \
           --volume="$NAME:/config:rw" --rm $NAME 
