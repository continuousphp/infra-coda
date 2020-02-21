#!/usr/bin/env bash

if [ $# -lt 2 ]
then
  echo -e "too few arguments!\n"
  echo -e "  bastion-ami.sh <version> <profile>"
  exit 128
fi

version=$1
profile=$2

aws --profile $2 ec2 describe-images --filters Name=name,Values=continuous-bastion-${version} \
--query 'Images[0].ImageId' --output text