#!/bin/bash

docker stop n64sdk-instance > /dev/null
docker rm n64sdk-instance > /dev/null
docker build -t n64sdk scripts
docker run --name n64sdk-instance -v "$(pwd)":/opt/src -i -t n64sdk bash
docker rm n64sdk-instance