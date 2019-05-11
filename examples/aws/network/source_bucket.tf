resource "aws_kms_key" "s3" {
  description             = "Key for S3 bucket encryption"
  deletion_window_in_days = 10

  tags {
    name = "ptfe-s3-bucket-key"
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.bucket_name}"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.s3.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning {
    enabled = true
  }

  tags {
    Name = "${var.bucket_name}"
  }
}
