# Automated Installation of PTFE with External Services in AWS
This branch contains Terraform configurations that can do an [automated installation](https://www.terraform.io/docs/enterprise/private/automating-the-installer.html) of [Private Terraform Enterprise](https://www.terraform.io/docs/enterprise/private/index.html) (PTFE) in AWS.

## Explanation of the Two Stage Deployment Model
It does this in two stages, each of which uses the open source flavor of Terraform:
1. It first deploys network and security group resources that the EC2 instances that run PTFE will run in along with a private S3 bucket to which the PTFE software, license, and settings files can be uploaded.
1. It then deploys the external PostgreSQL database and S3 bucket used in the [Production - External Services](https://www.terraform.io/docs/enterprise/private/preflight-installer.html#operational-mode-decision) operational mode of PTFE along with the primary and secondary EC2 instances that will run PTFE, an Application Load Balancer and associated resources, and some required IAM resources.

Since we are creating an S3 bucket in each of the stages, to avoid confusion, we refer to the bucket created in the first stage as the "PTFE source bucket" and the bucket created in the second stage as the "PTFE runtime bucket".

There are two reasons for splitting the deployment into two stages:
1. The main reason is that some users are not allowed to provision their own VPC, subnets, and security groups. Splitting the deployment allows those users who are allowed to provision all required AWS resources to first deploy the network and security group resources and the PTFE source bucket from the [network](./examples/aws/network) directory, copy the IDs of the VPC, subnets, and security groups into a terraform.tfvars file in the [aws](./examples/aws) directory, and then deploy the rest of the resources.
1. The second reason is that some users want to be able to "repave" their PTFE instances periodically, meaning that they will destroy the instances and recreate them (possibly with a new AMI). These users need to create the PTFE source bucket and then place the PTFE software, license file, and possibly settings files in it before they run the Terraform code in the second stage.

## Description of the User Data Script that Installs PTFE
During the second stage, a user data script is also run on each instance to install PTFE on it and to initialize the PostgreSQL database and S3 bucket if that has not already been done. The user data script is templated so that all relevant PTFE settings, whether entered in the terraform.tfvars file or computed by Terraform, are passed into it before it is run when the instances are deployed. The script writes out the replicated.conf and ptfe-settings.json files, installs the AWS CLI and uses it to retrieve the PTFE license file and software from the PTFE source bucket, configures SELinux to run in permissive mode, installs the psql utility, connects to the PostgreSQL database and creates the three required schemas needed by PTFE, and then finally runs the PTFE installer script. This automates the installation using the replicated.conf, ptfe-settings.json, and ptfe-license.rli files that it previously wrote to disk. Note that the PTFE installer script installs Docker on top of which PTFE runs.

Note: Currently, we only get the PTFE license from the PTFE source bucket and do an [online](https://www.terraform.io/docs/enterprise/private/install-installer.html#run-the-installer-online) installation, but we will soon retrieve the other PTFE artifacts mentioned and do an [airgapped](https://www.terraform.io/docs/enterprise/private/install-installer.html#run-the-installer-airgapped) installation.

## Prerequisites
You need to have the following things before running the first stage Terraform code in the [network](./examples/aws/network) directory of this repository:
* An AWS account
* An AWS KMS key in that account (which is used to encrypt/decrypt the contents of both S3 buckets)

You need to have the following things before running the second stage Terraform code in the [aws](./examples/aws) directory of this repository:
* an AWS account
* An AWS KMS key in that account (which is used to encrypt/decrypt the contents of both S3 buckets)
* a VPC like the one provisioned in stage 1
* two subnets in that VPC like the ones provisioned in stage 1
* a security group like the one provisioned in stage 1
* an S3 bucket like the one provisioned in stage 1 (to be used as the PTFE source bucket)
* An AWS AMI running a [supported flavor](https://www.terraform.io/docs/enterprise/private/preflight-installer.html#linux-instance) of Linux in the region in which you plan to deploy PTFE
* An AWS key pair that can be used to SSH to the EC2 instances that will be provisioned to run PTFE.
* A certificate uploaded into or created within Amazon Certificate Manager (ACM) that can be attached to the application load balancer that will be provisioned in front of the EC2 instances.
* An existing AWS Route 53 zone to host the Route 53 record set that will be provisioned.
* Access to a PTFE license, PTFE airgap bundle, and replicated.tar.gz installer bootstrapper that you can upload to the PTFE source bucket.

## A Comment About Certs
The Terraform code in this branch of this repository uses self-signed certs generated by PTFE on the EC2 instances but expects you to provide your own cert that can be deployed to the application load balancer which it provisions. Ideally, that would be a cert signed by a public certificate authority to better support integration with version control systems. It is possible to use a cert signed by a private certificate authority, but you then need to make sure that your VCS system (if using one of our [supported VCS integrations](https://www.terraform.io/docs/enterprise/vcs/index.html)) trusts that certificate authority.

## Supported Linux Flavors
The Terraform code in this branch currently supports Ubuntu.

## Legal Notice
Please note, that this repository may contain a sample of a code, which is used for purposes of example only (“Example Code”) and which may be used in other documentation, guides and training materials. However, notwithstanding any agreement, HashiCorp disclaims any warranties and liabilities in respect to Example Code. You acknowledge that the Example Code is not part of any of HashiCorp product and is not supported by HashiCorp.  If you have questions or issues with deploying or configuring Terraform Enterprise in your environment, please submit a ticket through [Customer Support Center] (https://www.hashicorp.com/support) or contact your Technical Account Manager
