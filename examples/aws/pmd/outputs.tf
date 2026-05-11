# Copyright IBM Corp. 2018, 2026

output "pmd_fqdn" {
  value = "${aws_route53_record.pmd.fqdn}"
}
