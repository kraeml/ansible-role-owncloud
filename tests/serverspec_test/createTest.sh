#!/bin/bash
read -n1 -p "Test ownloud-server or ubuntu-16.04? [o,u]: " doit
case $doit in
  o|O) distribution=owncloud && version=server;;
  u|U) distribution=ubuntu && version=16.04;;
  *) echo dont know ;;
esac

echo
echo "Building docker image for testing"
docker build --rm=true --file=../Dockerfile.${distribution}-${version} --tag=${distribution}-${version}:ansible ../

echo
echo "Running Testdummy"
docker run --detach -ti --name testcontainer ${distribution}-${version}:ansible /bin/bash

echo
echo "Executing tests:"
TARGET_CONTAINER=testcontainer TARGET_IMAGE=${distribution}-${version}:ansible rake spec

echo
echo "Cleaning up"
docker rm -f testcontainer
#docker rmi ${distribution}-${version}:ansible
