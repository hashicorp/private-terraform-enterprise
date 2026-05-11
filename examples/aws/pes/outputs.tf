# Copyright IBM Corp. 2018, 2026

output "pes_fqdn" {
  value = "${aws_route53_record.pes.fqdn}"
}
