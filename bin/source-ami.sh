#!/usr/bin/env bash

if [ $# -lt 2 ]
then
  echo -e "too few arguments!\n"
  echo -e "  source-ami.sh <profile> <region>"
  exit 128
fi

aws --profile $1 --region $2 ec2 describe-images --filters Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20191002 \
--query 'Images[0].ImageId' --output text

