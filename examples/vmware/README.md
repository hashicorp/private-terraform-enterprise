# ptfe-vmware-sample

### This code is provided as an example of how to deploy Private Terraform Enterprise onto vSphere using terraform as part of the Reference Architecture Document on the same topic. There are numerous things you must alter in order to get this to work. Please read the following directions carefully. Please note this repo is provided as an example only and is not HashiCorp supported code. If you have questions or issues around deploying Private Terraform Enterprise please contact your Technical Account Manager or support. 

## Prerequisites

This example assumes you are deploying Private Terraform Enterprise into a v6.x VMWare environment. This has not been tested against v5 or v7. All testing was done against v6.5

Assumptions made by this example - 
  * You have an existing postgres database you will use containing the following schemas - rails, vault, and registry. 
  * The postgres user has sufficient access to install modules.
  * An S3 bucket exists and is configured. 
  * You must have an AWS access and secret key to access the S3 bucket. 
  * You have sufficient access to the vSphere host to create a VM from a template and configure it.
  * You have a linux-based template configured to allow ssh as root (at least for the initial deployment - ssh as root can be disabled after.)
  * You have a valid DNS registration for your server.
  * You have a valid license file provided by HashiCorp.
  * Terraform is installed on your local machine (or the machine you still be running this from.)

## Getting the Example working for you

Clone this repo to your local computer - `git clone git@github.com:amy-hashi/ptfe-vmware-sample.git`

This repo contains the following files:  
```ptfe-vmware-sample/  
├── application-install/        <- Contains the files necessary to install/configure the application  
│   ├── replicated-install.sh   <- The script that will initiate the application install  
│   ├── replicated.conf         <- A config file for replicated specifying where files are located  
│   └── settings.json           <- Settings for the application   
├── README.md  
├── main.tf                     <- Terraform code to deploy infrastructure and application  
├── terraform.tfvars            <- Variable values go here  
└── variables.tf                <- Variable definitions and options  
```
1. First open the main.tf file and note the lines with comments. If you use datastore clusters/RDS you will need to comment out lines 15-18 + 43 and uncomment lines 20-23 + 45.

2. If you do use datastore clusters, open the variables.tf and comment out line 7 and uncomment line 10.

3. Open up terraform.tfvars and populate with the appropriate information. Again, if you use datastore clusters, you'll need to make a change. Comment out line 8 and uncomment line 11. All uncommented lines are REQUIRED.

4. In the application-settings folder update the replicated-install.sh file with your IP addresses.

5. Update the replicated.conf file with the console password you want to use. (This is for the application console.)

6. Update the settings.json with your infromation where appropriate. All values you need to replace (at a minimum) have REPLACE WITH... in them. 

7. Copy your license file into the appication-install directory. 

You can then run `terraform init`, `terraform plan` and `terraform apply`. 


