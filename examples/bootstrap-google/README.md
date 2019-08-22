This module preps your gcp project for a v5 installs. This will create a vpc, subnet and firewall, as well as generate a certificate.

## Pre-req

The only thing required to be previously conifgured is:

- A DNS zone in gcp
- A project
- Valid credentials stored in json format

## required variables

- `project` -- name of the gcp project to install into
- `creds` -- path to and name of the json credential file to use
- `domain` -- the domain to be used
- `dnszone` -- the pre-configured dnszone

