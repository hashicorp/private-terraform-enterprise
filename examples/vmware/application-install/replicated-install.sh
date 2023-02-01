#!/bin/sh
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


curl -o install.sh https://install.terraform.io/ptfe/stable

# Replace the private and public IP addresses with your information. If you do not have seperate public/private IPs, use the same IP for both.
bash ./install.sh no-proxy private-address=##.##.##.## public-address=##.##.##.##