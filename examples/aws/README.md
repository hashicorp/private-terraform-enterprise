## Installation

1. Ensure that you have an AWS Route53 Hosted Zone matching hashidemos.io. configured.  Only the standard NS/SOA are needed.  The install will create <namespace>-<installation type>.hashidemos.io
1. Ensure you have AWS credentials setup in ${HOME}/.aws
1. Ensure you have created a local SSH key pair and uploaded the public key to your AWS account.  Generate the key pair with ssh-keygen e.g.:
```text
ssh-keygen -t rsa -b 4096 -f ~/.ssh/<your name>-aws -N ''
```
1. Get yourself a license for use with TFE - file should end .rli
1. Edit the `terraform.tfvars.example`, and save the file as `terraform.tfvars`
  1. To work out the latest marketplace AMI to use for Ubuntu 18.04, you can run
```text
aws ec2 describe-images --owners 099720109477 --query "Images[*].[CreationDate,Name,ImageId]" --filters "Name=name,Values=ubuntu-minimal*18.04*amd64*" --region eu-west-2 --output table | sort -r | grep -Ev "^[-+]|DescribeImages" | head -1 | tr -d ' ' | awk -F\| '{print $4}'
```
or for RHEL
```text
aws ec2 describe-images --owners 309956199498 --query "Images[*].[CreationDate,Name,ImageId]" --filters "Name=name,Values=RHEL-7.?*GA*" --region eu-west-2 --output table | sort -r | grep -Ev "^[-+]|DescribeImages" | head -1 | tr -d ' ' | awk -F\| '{print $4}'
```
1. Edit the user-data.tpl
  1. Change the hostname so the FQDN matches a hosted zone as created above <your name>.hashidemos.io
  1. Change the installation type to 'poc' from 'production' if you are using a demo installation
  1. Note that the user-data.tpl is setup for online installation.  For an airgapped installation, you'll get asked for this during the UI part of the install.
1. Edit the main.tf and comment out two of the module calls so that only the one you need is uncommented.  
1. Ensure you have terraform v11.14 in your path.  You can get this from (here)[https://releases.hashicorp.com/terraform/0.11.14/]
1. Run `./terraform init`
1. Run `./terraform plan`
1. If that proceeds OK, run `./terraform apply`
1. Record the aws_route53_record IP
1. If you don't have an SSL certificate (e.g. *.crt, *.key) for use, you can use a self-signed certificate.  Generate this on your local machine using this example which generates a self-signed certificate valid for one-year only:
```text
openssl req -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout server.key -out server.crt
```
Specify blank or . for every field other than Common Name (CN) which should match a DNS-available address.  This works with just the recorded IP of the server.
1. Once this has completed, check the AWS console for when the instance is online, and then hit the URL you mentioned in the CN of the server.crt creation step on port 8800
1. Specify the address (or IP) of the hostname and click self-signed cert as per normal setup, uploading the license when asked.
1. The replicated UI will prompt for a password - the TF output will have output a suggested random one.
1. Preflight checks should complete OK (at least they have been tested successfully with an Ubuntu 18.04LTS host) and you should be into the replicated admin console.  Make sure to select the Installation Type before attempting to start the service.
