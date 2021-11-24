#!/bin/bash

version=4.2.3.4;
org=ossua;
app=it-redmine;

DOCKER_BUILDKIT=1 docker build --rm -f Dockerfile -t $org/$app:latest .;
DOCKER_BUILDKIT=1 docker build --rm -f Dockerfile -t $org/$app:$version .;
DOCKER_BUILDKIT=1 docker build --rm -f alpine.Dockerfile -t $org/$app:latest-alpine .;
DOCKER_BUILDKIT=1 docker build --rm -f alpine.Dockerfile -t $org/$app:$version-alpine .;

docker push $org/$app:latest;
docker push $org/$app:$version;
docker push $org/$app:latest-alpine;
docker push $org/$app:$version-alpine;
