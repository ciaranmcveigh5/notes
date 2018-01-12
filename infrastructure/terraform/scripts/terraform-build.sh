#!/usr/bin/env bash
set -o errexit
# set -o xtrace

[[ -z "$1" ]] && { echo "Usage: terraform-taint.sh app_name" ; exit 1; }

app_name=$1

source ./terraform-helper-functions.sh


function apply(){
  ##### Terraform Infra Setup #####
  pushd ../configurations/$app_name

  terraform init
  terraform apply
}

apply #2> terraform-build.log
