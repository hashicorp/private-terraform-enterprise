variable "aws_region" {
  description = "AWS region"
}

variable "aws_instance_ami" {
  # ami-0565af6e282977273 for Ubuntu
  # ami-011b3ccf1bd6db744 for RHEL
  # ami-02eac2c0129f6376b for CentOS
  description = "Amazon Machine Image ID"
}

variable "aws_instance_type" {
  # Should be m5.large for POCs
  # Should be m5.xlarge or m5.2xlarge for production
  description = "EC2 instance type"
}

variable "public_ip" {
    description = "should ec2 instance have public ip?"
    default = true
}

variable "alb_internal" {
  description = "whether ALB is internal or not"
  default = false
}

variable "route53_zone" {
  description = "name of Route53 zone to use"
}

variable "database_storage" {
  # Use 10 for demo, 20 for POC, 50 for production
  description = "allocated storage for RDS database"
  default = "10"
}

variable "database_instance_class" {
  # Use db.t2.medium for demo, db.m4.large for POC
  # Use db.m4.large, db.m4.xlarge or db.m4.2xlarge for production
  description = "instance class for RDS database"
  default = "db.t2.medium"
}

variable "database_multi_az" {
  # Use "false" for demo, "true" for POC or production
  description = "boolean indicating whether to run multi-az RDS"
  default = "false"
}

variable "create_second_instance" {
  # Set to 1 if you want a second PTFE instance, else 0
  description = "whether to create second PTFE instance"
  default = "0"
}

variable "namespace" {
  # Can have alphanumeric characters and hyphens.
  # Other characters might be ok but have not been tested
  description = "Unique name to use for DNS and resource naming"
}

variable "ssh_key_name" {
  # Whatever AWS allows which seems to be any characters
  description = "AWS key pair name to install on the EC2 instance"
}

variable "vpc_id" {
  description = "ID of VPC"
}

# Please include at least 2 subnets from your VPC.
variable "ptfe_subnet_ids" {
  # Enter in form "subnet_1, subnet_2"
  description = "Subnet IDs of subnets for EC2 instances in VPC"
}

# Please include at least 2 subnets from your VPC.
variable "db_subnet_ids" {
  # Enter in form "subnet_1, subnet_2"
  description = "Subnet IDs of DB subnets in VPC"
}

variable "security_group_id" {
  description = "ID of security group to attach to EC2 and PostgreSQL RDS instances"
}

variable "ssl_certificate_arn" {
  # Full ARN of SSL cert
  description = "ARN of an SSL certificate uploaded to IAM or AWS Certificate Manager for use with PTFE ELB"
}

variable "owner" {
  # Used within HashiCorp accounts for resource reaping
  description = "EC2 instance owner"
  default = ""
}

variable "ttl" {
  # Used within HashiCorp accounts for resource reaping
  description = "EC2 instance TTL"
  default     = "-1"
}

variable "linux" {
  # Be sure to set aws_instance_ami variable above
  # to an actual Ubuntu, RHEL, or CentOS AMI
  description = "ubuntu, rhel, or centos"
  default = "ubuntu"
}

### Variables for user_data script that installs PTFE

variable "ptfe_admin_password" {
  # Any characters
  description = "password for PTFE admin console (at port 8800)"
}

variable "hostname" {
  description = "the DNS hostname you will use to access PTFE"
  default = ""
}

variable "ca_certs" {
  # JSON does not allow raw newline characters, so replace any newlines in the data with \n
  description = "custom certificate authority (CA) bundle"
  default = ""
}

variable "installation_type" {
  # This can be "poc" or "production"
  description = "PTFE deployment mode"
  default = "production"
}

variable "production_type" {
  description = "external or disk"
  default = "external"
}

variable "capacity_concurrency" {
  description = "number of concurrent plans and applies; defaults to 10"
  default = "10"
}

variable "capacity_memory" {
  description = "The maximum amount of memory (in megabytes) that a Terraform plan or apply can use on the system; defaults to 256"
  default = "256"
}

variable "enc_password" {
  description = "Set the encryption password for the install"
}

variable "enable_metrics_collection" {
  description = "whether PTFE's internal metrics collection should be enabled"
  default = "true"
}

variable "extra_no_proxy" {
  description = "a comma separated list of hosts to exclude from proxying"
  default = ""
}

variable "pg_dbname" {
  # Up to 63 alphanumeric characters
  description = "Name of PostgreSQL database"
  default = "ptfe"
}

variable "pg_extra_params" {
  # See https://www.terraform.io/docs/enterprise/private/automating-the-installer.html#pg_extra_params
  description = "extra parameters for PostgreSQL"
  default = "sslmode=require"
}

variable "pg_password" {
  # Contains from 8 to 128 printable ASCII characters (excluding /,", and @)
  description = "Password for PostgreSQL database"
}

variable "pg_user" {
  # Can only contain alphanumeric characters
  description = "Name of PostgreSQL database user"
  default = "ptfe"
}

variable "placement" {
  # Always set to "placement_s3"
  description = "Set to placement_s3 for S3"
  default = "placement_s3"
}

variable "aws_instance_profile" {
  # Always set to "1"
  description = "use credentials from the AWS instance profile"
  default = "1"
}

variable "s3_bucket" {
  # Name of the PTFE runtime bucket that should be created
  description = "Name of the S3 bucket"
}

variable "s3_region" {
  description = "region of the S3 bucket"
}

variable "s3_sse" {
  # Always use "aws:kms"
  description = "enables server-side encryption of objects in S3."
  default = "aws:kms"
}

variable "s3_sse_kms_key_id" {
  # Just give the KMS key id, not the full ARN
  description = "An optional KMS key for use when S3 server-side encryption is enabled"
}

variable "vault_path" {
  description = "Path on the host system to store the vault files"
  default = "/var/lib/tfe-vault"
}

variable "vault_store_snapshot" {
  description = "whether vault files should be stored in snapshots"
  default = "1"
}

variable "tbw_image" {
  # Can be "default_image" or "custom_image"
  description = "whether to use standard or custom Terraform worker image"
  default = "default_image"
}
variable "custom_image_tag" {
  description = "alternative Terraform worker image name and tag"
  default = "hashicorp/build-worker:now"
}

variable "source_bucket_name" {
  # Name of the source PTFE bucket (not the ARN)
  description = "Name of the S3 PTFE source bucket containing PTFE license file, airgap bundle, replicated tar file, and settings files"
}

variable "ptfe_license" {
  # NAme of the S3 PTFE source bucket object containing
  # the PTFE license
  description = "key of license file within the source S3 bucket"
}

variable "operational_mode" {
  # Set to "online" or "airgapped"
  description = "whether installation is online or airgapped"
  default = "online"
}

variable "airgap_bundle" {
  # Name of the S3 PTFE source bucket object containing
  # the airgap bundle
  description = "S3 bucket object container airgap bundle"
  default = ""
}

variable "replicated_bootstrapper" {
  # Name of the S3 PTFE source bucket object containing
  # the replicated bootstrapper (replicated.tar.gz)
  description = "S3 bucket object containing replicated bootstrapper replicated.tar.gz"
  default = ""
}

variable "docker_package" {
  # Name of the S3 PTFE source bucket object containing
  # the main docker package
  description = "S3 bucket object containing Docker"
}

variable "docker_cli_package" {
  # Name of the S3 PTFE source bucket object containing
  # the docker CLI package
  description = "S3 bucket object containing Docker CLI"
}

variable "containerd_package" {
  # Name of the S3 PTFE source bucket object containing
  # the containerd package used by Docker
  description = "S3 bucket object containing containerd"
}

variable "libltdl7_package" {
  # Name of the S3 PTFE source bucket object containing
  # the libltdl7 package used by Docker
  description = "S3 bucket object containing libltdl7"
}

variable "container_selinux_package" {
  # Name of the S3 PTFE source bucket object containing
  # the container_selinux package used by Docker
  description = "S3 bucket object containing container-selinux"
}

variable "create_first_user_and_org" {
  # set to "true" for first install and "false" after that
  description = "whether to create the first site admin and org"
}

variable "initial_admin_username" {
  description = "username of initial site admin user in PTFE"
}

variable "initial_admin_email" {
  description = "email of initial site admin user in PTFE"
}

variable "initial_admin_password" {
  description = "username of initial site admin user in PTFE"
}

variable "initial_org_name" {
  description = "name of initial organization in PTFE"
}

variable "initial_org_email" {
  description = "email of initial organization in PTFE"
}
