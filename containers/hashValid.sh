#! /bin/bash

app=$1
hash=$2

aws ecr describe-images --region eu-west-2 --repository-name spike/${app} --query imageDetails[*].imageTags | grep -q ${hash}

echo $? > /tmp/hashValid${app}
