# Terraform Enterprise: High Availability for AWS - Bootstrap Example

This module preps your AWS accoutn for a clustered install.
This will create a VPC with subnets, and can create a Route53 zone.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_tags | A map of additional tags to attach to all resources created. | map | `{}` | no |
| availability\_zones | List of the Availability zones to use. | list | `[ "us-east-2a", "us-east-2b", "us-east-2c" ]` | no |
| cidr\_block | CIDR block range to use for the network. | string | `"10.0.0.0/16"` | no |
| domain\_name | The domain to create a route53 zone for. (eg. `tfe.example.com`), will not create if left empty. | string | `""` | no |
| prefix | The prefix to use on all resources, will generate one if not set. | string | `""` | no |
| private\_subnet\_cidr\_block | CIDR block range to use for the private subnet. | string | `"10.0.128.0/17"` | no |
| public\_subnet\_cidr\_block | CIDR block range to use for the public subnet. | string | `"10.0.0.0/17"` | no |

## Outputs

| Name | Description |
|------|-------------|
| route53\_domain\_name | The name of the hosted zone |
| route53\_zone\_id | Hosted Zone ID |
| route53\_zone\_name\_servers | List of name servers for the created zone. You will still need to delegate the created name servers for the zone to your main dns provider. |
| subnet\_tags | The tags associated with the subnets created |
| vpc\_id | The id of the created VPC |

## Liability


Please note, that this repository may contain a sample of a code, which is used for purposes of example only (“Example Code”) and which may be used in other documentation, guides and training materials. However, notwithstanding any agreement, HashiCorp disclaims any warranties and liabilities in respect to Example Code. You acknowledge that the Example Code is not part of any of HashiCorp product and is not supported by HashiCorp.  If you have questions or issues with deploying or configuring Terraform Enterprise in your environment, please submit a ticket through the [Customer Support Center](https://www.hashicorp.com/support) or contact your Technical Account Manager.
