# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "demo_fqdn" {
  value = "${aws_route53_record.demo.fqdn}"
}
