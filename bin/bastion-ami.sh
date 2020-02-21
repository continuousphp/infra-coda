#!/usr/bin/env bash

if [ $# -lt 3 ]
then
  echo -e "too few arguments!\n"
  echo -e "  bastion-ami.sh <version> <region> <profile>"
  exit 128
fi

version=$1
region=$2
profile=$3

aws --profile ${profile} --region ${region} ec2 describe-images --filters Name=name,Values=continuous-bastion-${version} \
--query 'Images[0].ImageId' --output text
