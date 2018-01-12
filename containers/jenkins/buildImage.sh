#! /bin/bash

docker build --no-cache -t 123.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins-data:latest -f Dockerfile.data .
docker build --no-cache -t 123.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins:latest .

aws ecr get-login --region eu-west-2 > login.txt
cut -d' ' -f1-6,9- login.txt | sh

docker push 123.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins-data:latest
docker push 123.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins:latest
