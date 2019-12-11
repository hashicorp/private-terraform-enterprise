This module prepares your GCP project for a v5 installation. This will create a VPC, subnet, firewall, and generate a certificate.

## Prerequisites

The only thing required to be previously conifgured is:

- A GCP project
- A DNS zone in the GCP project
- Valid credentials for a service account stored in json format

## required variables

- `project` -- name of the gcp project to install into
- `creds` -- path to and name of the json credential file to use
- `domain` -- the domain to be used
- `dnszone` -- the pre-configured dnszone

## optional variables

- `frontenddns` -- the prepended value to be added to your domain
- `vpc_name` -- the name of the VPC to be created
- `subnet_name` -- the name of the subnet to be created within the specified VPC
- `subnet_range` -- the CIDR range to be allocated for the subnet
- `primaryhostname` -- the hostname of the primary node(s)
- `healthchk_ips` -- List of gcp health check ips to allow through the firewall (default value is suggested)
