# Terraform Enterprise: High Availability for Azure - Bootstrap Example

This module preps your Azure subscription for a clustered install.
This will create a Resource Group, Virtual Network, associated Subnet with Network Security Group attached, as well as a Key Vault.

The only required inputs are a object-id and tenant-id to give access to the key-vault to be able to interact with.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| key\_vault\_object\_id | The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault. | string | n/a | yes |
| key\_vault\_tenant\_id | The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. | string | n/a | yes |
| additional\_tags | A map of additional tags to attach to all resources created. | map | `{}` | no |
| address\_space | CIDR block range to use for the network. | string | `"10.0.0.0/16"` | no |
| address\_space\_allowlist | CIDR block range to use to allow traffic from | string | `"*"` | no |
| location | The Azure location to build resources in. | string | `"Central US"` | no |
| prefix | The prefix to use on all resources, will generate one if not set. | string | `""` | no |
| subnet\_address\_space | CIDR block range to use for the subnet if a subset of `address_space`. Defaults to `address_space` | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| key\_vault\_name |  |
| resource\_group\_name |  |
| subnet |  |
| virtual\_network\_name |  |

### Liability

Please note, that this repository may contain a sample of a code, which is used for purposes of example only (“Example Code”) and which may be used in other documentation, guides and training materials. However, notwithstanding any agreement, HashiCorp disclaims any warranties and liabilities in respect to Example Code. You acknowledge that the Example Code is not part of any of HashiCorp product and is not supported by HashiCorp.  If you have questions or issues with deploying or configuring Terraform Enterprise in your environment, please submit a ticket through the [Customer Support Center](https://www.hashicorp.com/support) or contact your Technical Account Manager.
