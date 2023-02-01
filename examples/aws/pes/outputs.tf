# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "pes_fqdn" {
  value = "${aws_route53_record.pes.fqdn}"
}
