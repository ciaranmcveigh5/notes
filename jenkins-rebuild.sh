#! /bin/bash

pushd containers/jenkins

docker build --no-cache -t 1234.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins-data -f Dockerfile.data .
docker build --no-cache -t 1234.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins .

popd

aws ecr get-login --region eu-west-2 > login.txt
cut -d' ' -f1-6,9- login.txt | sh

docker push 1234.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins-data:latest
docker push 1234.dkr.ecr.eu-west-2.amazonaws.com/project/static/jenkins:latest

awk 'FNR == 35 {print $2}' infrastructure/terraform/configurations/jenkins/task-definitions/jenkins.json > ifTest.txt

if grep -q "TESTPIN0" ifTest.txt; then
  sed -i'' -e '35s/.*/\            "name": "TESTPIN1",/' infrastructure/terraform/configurations/jenkins/task-definitions/jenkins.json
else
  sed -i'' -e '35s/.*/\            "name": "TESTPIN0",/' infrastructure/terraform/configurations/jenkins/task-definitions/jenkins.json
fi

pushd infrastructure/terraform/configurations/jenkins

terraform apply

popd
