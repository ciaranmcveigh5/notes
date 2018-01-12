#!/usr/bin/env bash

# export TF_LOG=TRACE

function list_instances(){
  terraform state list | grep 'module.ec2_instance_new.aws_instance.i' | tr '.' '\t' | tr '[' ' \t' | tr -d ']' | awk '{print "-module=" $2 " " $3 "." $4 ($5 != "" ? "." $5 : "") }'
}

function list_instance_dns(){
  terraform state list | grep 'module.ec2_instance_new.aws_instance.i' | xargs -L1 terraform state show | grep private_ip | awk '{print $3}'
}

function wait_fot_ssh(){
  if [[ `uname` == 'Darwin' ]]; then
    jump_shell='ssh test-bastion.digi-leap.com'
  elif [[ `uname` == 'Linux' ]]; then
    jump_shell='/bin/bash -c'
  fi

  list_instance_dns | xargs -L1 -I % $jump_shell 'while ! nc -w1 % 22 < /dev/null; do sleep 1; done'
}

function run_terraform(){
  # terraform plan -out=.execution_plan -refresh=false -detailed-exitcode $1 && rc=$? || rc=$?
  terraform plan -out=.execution_plan -detailed-exitcode $1 && rc=$? || rc=$?

  if [ $rc -eq 2 ]; then
    terraform apply .execution_plan
    run_terraform "$1"
  elif [ $rc -eq 1 ]; then
    exit 1;
  fi
}
