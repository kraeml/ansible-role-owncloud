#!/bin/bash
echo "Building docker image:"
docker build --rm=true --file=../Dockerfile.ubuntu-16.04 --tag=ubuntu-16.04:ansible ../

echo "Running Testdummy"
docker run -tdi --name testcontainer ubuntu:16.04 /bin/bash

echo
echo "Executing tests:"
TARGET=testcontainer rake spec
