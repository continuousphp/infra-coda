#include .env

ifndef AWS_PROFILE
$(error You must specify AWS_PROFILE parameter)
endif
ifndef roleArn
$(error You must specify roleArn parameter)
endif
ifndef KeyName
$(error You must specify KeyName parameter. create your key pair in AWS Console)
endif
ifndef region
$(error You must specify region parameter)
endif
ifndef BUCKET
$(error You must specify BUCKET parameter)
endif
ifndef CODA_BUCKET_SECRETS
$(error You must specify CODA_BUCKET_SECRETS parameter)
endif
ifndef AWS_BUILD_SUBNET
$(error You must specify AWS_BUILD_SUBNET parameter)
endif
ifndef NOTIFY_EMAIL
$(error You must specify NOTIFY_EMAIL parameter)
endif

env?=staging
version?=$(shell ./ci/version.sh)
region?=us-east-1
appName?=Coda
stack_name?=$(appName)-$(region)-$(env)
AWS_SOURCE_AMI?=$(shell ./bin/source-ami.sh $(AWS_PROFILE) $(region))
BastionVersion?=dev-master
KeyName?=code-infra-test
AWS_PROFILE?=coda
AWS_AMI_USER?=ubuntu
AWS_DISTRIBUTION?=Ubuntu
BastionAmiVersion?=1.0.2-1e231703-9044-4c58-b471-4b6345daf4a4-ami-0eb177f6a414935d8.4
AWS_INSTANCE_BUILD_TYPE?=t2.micro
AWS_INSTANCE_TYPE?=c5.2xlarge
BastionAmiId?=$(shell ./bin/bastion-ami.sh $(BastionAmiVersion)  $(region) $(AWS_PROFILE) )
CodaAmiId?=$(shell ./bin/coda-ami.sh  $(AWS_PROFILE) $(env))
BUCKET?=init-stack-templatebucket-h0zgfseupync
CodaInstanceType?=c5.2xlarge
## Condtionnal start of the stacks
RunVpcStack?=true
RunBastionStack?=true
RunCodaStack?=true
RunCodaWorkerStack?=true
NbAzs=$(shell ./bin/getRegionAzs.sh $(region) $(AWS_PROFILE))

## Install packer
packer-install:
	sudo $(PWD)/ci/install_packer.sh /usr/local/

## Update aws-cli
update-aws-cli:
	pip install awscli --upgrade --user

## Check packer template
packer-validate: update-aws-cli
	cd packer && packer inspect template.json && packer validate -var-file variables.json template.json

## Build Coda AMI using packer ansible local
build-ami:
	packer version
	cd packer && \
	PACKER_LOG=1 AWS_PROFILE=$(AWS_PROFILE) AWS_BUILD_SUBNET=$(AWS_BUILD_SUBNET) AWS_INSTANCE_BUILD_TYPE=${AWS_INSTANCE_BUILD_TYPE} \
	AWS_SOURCE_AMI=$(AWS_SOURCE_AMI) \
		packer build \
		-var-file variables.json \
		-var "playbook_version=$(version)" \
		-var "region=$(region)" \
		-var "env=$(env)" \
		template.json

## Package Cloud Formation template
package:
	  aws --profile $(AWS_PROFILE) \
		--region $(region) \
	  cloudformation package \
		--template-file cloudformation/stacks/main.yml \
		--s3-bucket $(BUCKET) \
		--output-template-file template-output.yml

## Deploy Cloud Formation stack
deploy: package
	aws --profile $(AWS_PROFILE) \
		--region $(region) \
	  cloudformation deploy \
		--template-file template-output.yml \
		--capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
		--role-arn $(roleArn) \
		--stack-name $(stack_name) \
		--parameter-overrides  \
			BastionAmiId=$(BastionAmiId) CodaAmiId=$(CodaAmiId) CodaWorkerAmiId=$(CodaAmiId)\
        	KeyName=$(KeyName) \
        	CodaInstanceType=$(CodaInstanceType) \
        	RunVpcStack=$(RunVpcStack) \
        	RunBastionStack=$(RunBastionStack) \
			CodaBucketInfra=$(CODA_BUCKET_SECRETS) \
			BucketInfra=$(BUCKET) \
			NotifyEmail=$(NOTIFY_EMAIL) \
			NumberOfAZs=$(NbAzs)

## Describe Cloud Formation stack outputs
describe:
	aws --profile $(AWS_PROFILE) \
		--region $(region) \
	  cloudformation describe-stacks \
		--stack-name $(stack_name) \
		--query 'Stacks[0].Outputs[*].[OutputKey, OutputValue]' --output text

## Delete Cloud Formation stack
delete:
	aws --profile $(AWS_PROFILE) \
		--region $(region) \
	  cloudformation delete-stack \
		--stack-name $(stack_name)
