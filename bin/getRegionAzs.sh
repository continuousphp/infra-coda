#!/bin/bash

aws ec2 describe-availability-zones --region $1 --profile $2 --query 'AvailabilityZones[*] |  length(@)' --output text