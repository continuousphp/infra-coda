#!/usr/bin/env bash

if [ $# -lt 1 ]
then
  echo -e "too few arguments!\n"
  echo -e "  coda-ami.sh <profile>"
  exit 128
fi

profile=$1
version=$2
aws --profile $1 ec2 describe-images --filters Name=tag:Name,Values=continuous-coda-$version \
--query 'Images[0].ImageId' --output text
