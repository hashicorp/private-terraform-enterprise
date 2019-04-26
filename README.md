# Automated Installation of PTFE with External Services in AWS
This branch contains Terraform configurations that can do [automated installations](https://www.terraform.io/docs/enterprise/private/automating-the-installer.html) of [Private Terraform Enterprise](https://www.terraform.io/docs/enterprise/private/index.html) (PTFE) in AWS using either Ubuntu, RHEL, or CentOS. This can currently be done in using the online installation method for all three operating systems and the airgapped installation method for Ubuntu and RHEL.

## Explanation of the Two Stage Deployment Model
We deploy the AWS infrastructure and PTFE in two stages, each of which uses the open source flavor of Terraform:
1. We first deploy network and security group resources that the EC2 instances that run PTFE will run in along with a private S3 bucket to which the PTFE software, license, and settings files can be uploaded.
1. We then deploy the external PostgreSQL database and S3 bucket used in the [Production - External Services](https://www.terraform.io/docs/enterprise/private/preflight-installer.html#operational-mode-decision) operational mode of PTFE along with the primary and secondary EC2 instances that will run PTFE, an Application Load Balancer and associated resources, and some required IAM resources.

Since we are creating an S3 bucket in each of the stages, to avoid confusion, we refer to the bucket created in the first stage as the "PTFE source bucket" and the bucket created in the second stage as the "PTFE runtime bucket".

There are two reasons for splitting the deployment into two stages:
1. The main reason is that some users are not allowed to provision their own VPC, subnets, and security groups. Splitting the deployment allows those users who are allowed to provision all required AWS resources to first deploy the network and security group resources and the PTFE source bucket from the [network](./examples/aws/network) directory, copy the IDs of the VPC, subnets, and security groups into a terraform.tfvars file in the [aws](./examples/aws) directory, and then deploy the rest of the resources.
1. The second reason is that some users want to be able to "repave" their PTFE instances periodically, meaning that they will destroy the instances and recreate them (possibly with a new AMI). These users need to create the PTFE source bucket and then place the PTFE software and license file in it before they run the Terraform code in the second stage.

## Description of the User Data Script that Installs PTFE
During the second stage, a user data script generated from one of five templates ([user-data-ubuntu-online.tpl](./examples/aws/user-data-ubuntu-online.tpl), [user-data-ubuntu-airgapped.tpl](./examples/aws/user-data-ubuntu-airgapped.tpl). [user-data-rhel-online.tpl](./examples/aws/user-data-rhel-online.tpl), [user-data-rhel-airgapped.tpl](./examples/aws/user-data-rhel-airgapped.tpl), or [user-data-centos-online.tpl](./examples/aws/user-data-centos-online.tpl)) is run on each instance to PTFE on it and to initialize the PostgreSQL database and S3 bucket if that has not already been done. The online scripts also install Docker. Since the user data script is templated, all relevant PTFE settings, whether entered in the terraform.tfvars file or computed by Terraform, are passed into it before it is run when the instances are deployed.

The script does the following things:
1. It determines the private IP, public IP, and private DNS of each EC2 instance being deployed to run PTFE.
1. It writes out the replicated.conf and ptfe-settings.json files.
1. It installs the aws CLI.
1. It uses the aws CLI to retrieve the PTFE license file from the PTFE source bucket.
1. On Ubuntu and CentOS, it sets SELinux to permissive mode. (This is not required on RHEL.)
1. It installs the psql utility, connects to the PostgreSQL database, and creates the three required schemas needed by PTFE.

At this point, different things happen depending on whether an online or airgapped installation is being done.
* In an an [online](https://www.terraform.io/docs/enterprise/private/install-installer.html#run-the-installer-online) installation, the script downloads the PTFE installer using curl and then runs the installer which installs both Docker and PTFE.
* In an [airgapped](https://www.terraform.io/docs/enterprise/private/install-installer.html#run-the-installer-airgapped) installation, the script downloads docker and packages it needs, the airgap bundle, and the replicated bootstrapper (replicated.tar.gz) from the PTFE source bucket, installs docker, and then runs the installer which installs PTFE.

In either case, the installer uses the replicated.conf, ptfe-settings.json, and ptfe-license.rli files that the script previously wrote to disk.

The script then enters a loop, testing the availability of the PTFE app with a curl command. When that finishes, the script uses the TFE API to create the first site admin user, a TFE API token for this user, and the first organization. This leverages the [Initial Admin Creation Token](https://www.terraform.io/docs/enterprise/private/automating-initial-user.html) (IACT). At this point, the generated API token could be used to automate additional PTFE configuration.

## Example tfvars Files
There are four example tfvars files that you can use with the Terraform configurations in this branch:
* [network.auto.tfvars.example](./examples/aws/network/network.auto.tfvars.example) for use in phase 1.
* [ubuntu.auto.tfvars.example](./examples/aws/ubuntu.auto.tfvars.example) for use in phase 2 when deploying to Ubuntu.
* [rhel.auto.tfvars.example](./examples/aws/rhel.auto.tfvars.example) for use in phase 2 when deploying to RHEL.
* [centos.auto.tfvars.example](./examples/aws/centos.auto.tfvars.example) for use in phase 2 when deploying to CentOS.

The second and third files can be used with both online and airgapped installations, but the fourth (for CentOS) can currently only be used for online installations. The various packages listed will be ignored when doing an online installation, but the variables must still be set to something.  You can use the current values or empty strings (""). When doing an online installation, be sure to set
operational_mode to "online".  When doing an airgapped installation, set it to "airgapped".

After doing an initial deployment, you should change create_first_user_and_org to "false" since the inital site admin user can only be created once.

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
* An AWS AMI running a Ubuntu, RHEL, or CentOS in the region in which you plan to deploy PTFE
* An AWS key pair that can be used to SSH to the EC2 instances that will be provisioned to run PTFE.
* A certificate uploaded into or created within Amazon Certificate Manager (ACM) that can be attached to the application load balancer that will be provisioned in front of the EC2 instances.
* An existing AWS Route 53 zone to host the Route 53 record set that will be provisioned.
* Access to a PTFE license
* Access to a PTFE airgap bundle and replicated.tar.gz installer bootstrapper that you can upload to the PTFE source bucket (if doing an airgapped installation).
* Access to Docker and packages it requires so that you can upload them to the PTFE source bucket (if doing an airgapped installation).

## A Comment About Certs
The Terraform code in this branch of this repository uses self-signed certs generated by PTFE on the EC2 instances but expects you to provide your own cert that can be deployed to the application load balancer which it provisions. Ideally, that would be a cert signed by a public certificate authority to better support integration with version control systems. It is possible to use a cert signed by a private certificate authority, but you then need to make sure that your VCS system (if using one of our [supported VCS integrations](https://www.terraform.io/docs/enterprise/vcs/index.html)) trusts that certificate authority.

## Repaving Your PTFE Instances With Terraform
You can replace or "repave" the EC2 instance(s) running PTFE with Terraform at any time by following this process:
1. Terminate the EC2 instance(s) in the AWS Console or taint them by running `terraform taint -module=pes aws_instance.primary` and/or `terraform taint -module=pes aws_instance.secondary`.
1. Re-run `terraform apply`. This will cause the EC2 instance(s) to be destroyed and recreated. In addition, it will cause the aws_lb_target_group_attachment resources associated with the application load balancer to be destroyed and recreated; this ensures that the ALB will always point to the primary PTFE instance.

When repaving instances, you should set the create_first_user_and_org variable to "false" since you will have already created the first site admin user and organization.
