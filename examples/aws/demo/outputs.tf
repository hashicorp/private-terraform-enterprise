# Copyright IBM Corp. 2018, 2026

output "demo_fqdn" {
  value = "${aws_route53_record.demo.fqdn}"
}
