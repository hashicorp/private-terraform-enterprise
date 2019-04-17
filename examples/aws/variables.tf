variable "aws_region" {
  description = "AWS region"
}

variable "aws_instance_ami" {
  description = "Amazon Machine Image ID"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
}

variable "namespace" {
  description = "Unique name to use for DNS and resource naming"
}

variable "ssh_key_name" {
  description = "AWS key pair name to install on the EC2 instance"
}

variable "vpc_id" {
  description = "ID of VPC"
}

# Please include at least 2 subnets from your VPC.
variable "subnet_ids" {
  description = "Subnet IDs of subnets in VPC"
}

variable "security_group_id" {
  description = "ID of security group to attach to EC2 and PostgreSQL RDS instances"
}

variable "ssl_certificate_arn" {
  description = "ARN of an SSL certificate uploaded to IAM or AWS Certificate Manager for use with PTFE ELB"
}

variable "route53_zone" {
  description = "name of Route53 zone to use"
  default = "hashidemos.io."
}

variable "alb_internal" {
  description = "whether ALB is internal or not"
  default = false
}

variable "owner" {
  description = "EC2 instance owner"
}

variable "ttl" {
  description = "EC2 instance TTL"
  default     = "-1"
}

variable "source_bucket_name" {
  description = "Name of the S3 source bucket containing PTFE license file, airgap bundle, replicated tar file, and settings files"
}

variable "ptfe_license" {
  description = "key of license file within the source S3 bucket"
}

### Variables for user_data script that installs PTFE

variable "ptfe_admin_password" {
  description = "password for PTFE admin console (at port 8800)"
}

variable "hostname" {
  description = "the DNS hostname you will use to access PTFE"
  default = ""
}

variable "ca_certs" {
  description = "custom certificate authority (CA) bundle"
  default = ""
}

variable "installation_type" {
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

###
variable "extra_no_proxy" {
  description = "a comma separated list of hosts to exclude from proxying"
  default = ""
}

variable "pg_dbname" {
  description = "Name of PostgreSQL database"
  default = "ptfe"
}

variable "pg_extra_params" {
  description = "extra parameters for PostgreSQL"
  default = "sslmode=require"
}

variable "pg_password" {
  description = "Password for PostgreSQL database"
}

variable "pg_user" {
  description = "Name of PostgreSQL database user"
  default = "ptfe"
}

variable "placement" {
  description = "Set to placement_s3 for S3"
  default = "placement_s3"
}

variable "aws_instance_profile" {
  description = "use credentials from the AWS instance profile"
  default = "1"
}

variable "s3_bucket" {
  description = "Name of the S3 bucket"
}

variable "s3_region" {
  description = "region of the S3 bucket"
}

variable "s3_sse" {
  description = "enables server-side encryption of objects in S3."
  default = "aws:kms"
}

variable "s3_sse_kms_key_id" {
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
