# Automated Installation of PTFE with External Services in AWS
This branch contains Terraform configurations that can do [automated installations](https://www.terraform.io/docs/enterprise/private/automating-the-installer.html) of [Private Terraform Enterprise](https://www.terraform.io/docs/enterprise/private/index.html) (PTFE) in AWS using either Ubuntu, RHEL, or CentOS. This can currently be done in using the online installation method for all three operating systems and the airgapped installation method for Ubuntu and RHEL.

## Explanation of the Two Stage Deployment Model
We deploy the AWS infrastructure and PTFE in two stages, each of which uses the open source flavor of Terraform:
1. We first deploy network and security group resources that the EC2 instances that run PTFE will run in along with a private S3 bucket to which the PTFE software, license, and settings files can be uploaded and a KMS key used to encrypt the bucket.
1. We then deploy the external PostgreSQL database and S3 bucket used in the [Production - External Services](https://www.terraform.io/docs/enterprise/private/preflight-installer.html#operational-mode-decision) operational mode of PTFE along with the primary and optional secondary EC2 instances that will run PTFE, an Application Load Balancer and associated resources, and some required IAM resources.

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
* [network.auto.tfvars.example](./examples/aws/network/network.auto.tfvars.example) for use in stage 1.
* [ubuntu.auto.tfvars.example](./examples/aws/ubuntu.auto.tfvars.example) for use in phase 2 when deploying to Ubuntu.
* [rhel.auto.tfvars.example](./examples/aws/rhel.auto.tfvars.example) for use in phase 2 when deploying to RHEL.
* [centos.auto.tfvars.example](./examples/aws/centos.auto.tfvars.example) for use in phase 2 when deploying to CentOS.

These files assume you are provisioning to the us-east-1 region. If you change this, make sure you select AMI IDs that exist in your region.

The second and third files can be used with both online and airgapped installations, but the fourth (for CentOS) can currently only be used for online installations. The various packages listed will be ignored when doing an online installation, but the variables must still be set to something.  You can use the current values or empty strings (""). When doing an online installation, be sure to set
`operational_mode` to "online".  When doing an airgapped installation, set it to "airgapped".

After doing an initial deployment, you should change `create_first_user_and_org` to "false" since the inital site admin user can only be created once.

## Prerequisites
You need to have an AWS account before running the first stage Terraform code in the [network](./examples/aws/network) directory of this repository.

You need to have the following things before running the second stage Terraform code in the [aws](./examples/aws) directory of this repository:
* an AWS account
* a VPC like the one provisioned in stage 1
* two subnets in that VPC like the ones provisioned in stage 1
* a security group like the one provisioned in stage 1
* an S3 bucket like the one provisioned in stage 1 (to be used as the PTFE source bucket)
* an AWS KMS key like the one provisioned in stage 1
* An AWS AMI running a Ubuntu, RHEL, or CentOS in the region in which you plan to deploy PTFE
* An AWS key pair that can be used to SSH to the EC2 instances that will be provisioned to run PTFE.
* An existing AWS Route 53 zone to host the Route 53 record set that will be provisioned.
* Access to a PTFE license
* Access to a PTFE airgap bundle and replicated.tar.gz installer bootstrapper that you can upload to the PTFE source bucket (if doing an airgapped installation).
* Access to Docker and packages it requires so that you can upload them to the PTFE source bucket (if doing an airgapped installation).

You can also provide the ARN of a certificate that you uploaded into or created within Amazon Certificate Manager (ACM). This will be attached to the listeners created for the application load balancer that will be provisioned in front of the EC2 instances. The Stage 2 Terraform code actually creates an ACM certificate whether you provide one or not, but if you do provide your own, the generated one is associated with a fake domain consisting of "fake-" concatenated to your hostname. This is currently required with Terraform 0.11.x in order to make the generation of an ACM cert optional. This will not be needed with Terraform 0.12 which has an improved conditional operator.

## Installing PTFE
Please follow these steps to deploy PTFE in your AWS account.

### Clone the Repository and Switch to Right Branch
1. On your local computer, navigate to a directory such as GitHub/hashicorp into which you want to clone this repository. The code in the next step will create a private-terraform-enterprise directory under whichever directory you start in.
1. Run `git clone https://github.com/hashicorp/private-terraform-enterprise.git` to clone the repository.
1. Run `cd private-terraform-enterprise` to navigate into the cloned repository.
1. Run `git checkout automated-aws-pes-installation` (to switch to the automated-aws-pes-installation branch).

### Provision Stage 1
If you want to use the Terraform code in the examples/aws/network directory to create the VPC, subnets, other network resources, security group, KMS key, and PTFE source bucket, then follow these steps. Otherwise, create the equivalent resources using some other method and then skip to Stage 2.

1. Run `cd examples/aws/network` to navigate to the examples/aws/network directory that contains the Stage 1 Terraform code.
1. Run `cp network.auto.tfvars.example network.auto.tfvars` to create your own tfvars file.
1. Edit network.auto.tfvars, set namespace to "<name>-ptfe", set bucket_name to the name of the PTFE source bucket you wish to create, and save the file.
1. Run `export AWS_ACCESS_KEY_ID=<your_aws_key>`.
1. Run `export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>`.
1. Run `export AWS_DEFAULT_REGION=us-east-1` or pick some other region.  But if you select a different region, make sure you select AMIs from that region.
1. Run `terraform init` to initialize the Stage 1 Terraform configuration and download providers.
1. Run `terraform apply` to provision the Stage 1 resources. Type "yes" when prompted. The apply takes about 1 minute.
1. Note the `kms_id`, `security_group_id`, `subnet_ids`, and `vpc_id` outputs which you will need in Stage 2.
1. Run `cd ..` to go back to the examples/aws directory.
1. Add your PTFE license file to your PTFE source bucket that was created. You can do this in the AWS Console. If doing an airgapped installation, then add your airgap bundle, replicated.tar.gz, and docker packages to the bucket too. We suggest naming the various objects in your PTFE source bucket to match the values given in the tfvars.example files.

### Provision Stage 2
Follow these steps to provision the Stage 2 resources.

1. Make sure you are in the examples/aws directory of the cloned repository.
1. If you skipped Stage 1, do steps 4-6 of that stage to export your AWS keys and default region.
1. Copy one of the tfvars.example files to a file with the same name but without the "example" extension.
1. Edit the "ptfe.<linux_flavor>.auto.tfvars" file where \<linux_flavor\> is the flavor of Linux you are using.
    * Set `namespace` to the same namespace you set in Stage 1.
    * Set `source_bucket_name` to the value of `bucket_name` you set in network.auto.tfvars.
    * Set `vpc_id`, `subnet_ids`, and `security_group_id` to the corresponding outputs from Stage 1 or the IDs of the resources you created using other means. Note, however, that subnet_ids should be given in the form "<subnet_1>,<subnet_2>" with no space after the comma.
    * Set `s3_sse_kms_key_id` to the `kms_id` output from Stage 1 or the ID of the KMS key you created using other means.
1. Set the rest of the variables in the file.
    * Set `aws_instance_type` to "m5.large" for demos and POCs, but set it to "m5.xlarge" or "m5.2xlarge" for production.
    * Set `database_storage` to the default "10" for demos, "20" for POCs, and "50" for production.
    * Set `database_instance_class` to the default "db.t2.medium" for demos, "db.m4.large" for POCs, and "db.m4.large", "db.m4.xlarge" or "db.m4.2xlarge" for production.
    * Set `database_multi_az` to the default "false" for demos, but set it to "true" for POCs and production.
    * Set `create_second_instance` to "1" if you want a second PTFE instance. Otherwise, leave it set to "0".
    * Set `ssh-keyname` to the name of your SSH keypair as it is displayed in the AWS Console.
    * Set `ssl_certificate_arn` to the full ARN of the certificate you uploaded into or created within Amazon Certificate Manager (ACM), but if you want Terraform to create an ACM cert for you, set this to "".
    * `owner` and `ttl` are used within HashiCorp's own AWS account for resource reaping purposes. You can leave these blank if you do not work at HashiCorp.
    * Set `ptfe_license` to the name of the object in your PTFE source bucket that contains your PTFE license.
    * Set the four password fields with suitable passwords.
    * Set `operational_mode` to "online" or "airgapped".
    * See [PTFE Automated Installation](https://www.terraform.io/docs/enterprise/private/automating-the-installer.html) for guidance on the various PTFE settings that are passed into the replicated.conf and ptfe-settings.json files in the `*.tpl` files.
    * If doing an airgapped installation, set the `airgap_bundle`, `replicated_bootstrapper`, and docker package variables to the names of the corresponding items that you placed in your PTFE source bucket.
    * If doing an initial installation, make sure `create_first_user_and_org` is set to "true".
    * Set the `initial_admin_*` properties to desired values.
1. Run `terraform init` to initialize the Stage 2 Terraform configuration and download providers.
1. Run `terraform apply` to provision the Stage 2 resources. Type "yes" when prompted. The apply takes about 10-15 minutes.  Most of the time is spent creating the PostgreSQL database in RDS.
1. After you see outputs for the apply, visit the AWS Console, and find your "\<namespace\>-instance-1" instance.
1. Click the Connect button and copy the SSH connection command.
1. Type that command in a shell that contains your SSH private key from your AWS key pair and connect to your primary PTFE instance.
1. You can now tail the install-ptfe.log with `tail -f install-ptfe.log`. Note that it is ok if you see multiple warnings in the log like "curl: (6) Could not resolve host: \<ptfe_dns\>".  This just means that the script has run the installer and is currently testing the availability of the PTFE application with curl every 15 seconds. If this lasts for more than 5 minutes, then something is wrong.
1. When the install-ptfe.log stops showing curl calls and instead shows output related to the creation of the initial admin user and organization, point a browser tab against `https://<ptfe_dns>`.
1. Enter your username and your password and start using your new PTFE server.

If you get any errors during the Stage 2 apply related to the creation of the EC2 instances or the ALB, you can try running `terraform apply` a second time.  Sometimes, AWS will give an error like "InvalidInstanceID.NotFound: The instance ID 'i-035b8268e714a911b' does not exist" when creating an EC2 instance even though it actually was created. If the second apply is successful, then the user-data script on the primary EC2 instance should be able to get out of the curl loop and create the initial site admin user and organization.

**Note that you do not need to visit the PTFE admin console at port 8800 when deploying PTFE with the process given on this branch of this repository.**

## A Comment About Certs
The Terraform code in this branch of this repository uses self-signed certs generated by PTFE on the EC2 instances and an ACM certificate on the listeners associated with the Application Load Balancer that it creates. As mentioned above, you can provide your own cert or let the Terraform code generate one for you. If you provide your own cert, it would ideally be a cert signed by a public certificate authority to better support integration with version control systems. It is possible to use a cert signed by a private certificate authority, but you then need to make sure that your VCS system (if using one of our [supported VCS integrations](https://www.terraform.io/docs/enterprise/vcs/index.html)) trusts that certificate authority.

## Repaving Your PTFE Instances With Terraform
You can replace or "repave" the EC2 instance(s) running PTFE with Terraform at any time by following this process:
1. Terminate the EC2 instance(s) in the AWS Console or taint them by running `terraform taint -module=pes aws_instance.primary` and/or `terraform taint -module=pes aws_instance.secondary`.
1. Re-run `terraform apply`. This will cause the EC2 instance(s) to be destroyed and recreated. In addition, it will cause the aws_lb_target_group_attachment resources associated with the application load balancer to be destroyed and recreated; this ensures that the ALB will always point to the primary PTFE instance.

When repaving instances, you should set the create_first_user_and_org variable to "false" since you will have already created the first site admin user and organization.
