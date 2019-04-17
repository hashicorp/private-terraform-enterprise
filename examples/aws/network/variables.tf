variable "aws_region" {
  description = "AWS region"
}

variable "namespace" {
  description = "Unique name to use for DNS and resource naming"
}

variable "bucket_name" {
   description = "Name of the PTFE source bucket to create"
}

variable "kms_key_arn" {
   description = "ARN of the KMS key that encrypts the source bucket"
}
