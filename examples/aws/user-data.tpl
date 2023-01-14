#!/bin/bash

# Get Licence
sudo apt-get update
sudo apt-get install -y awscli
sudo aws s3 cp s3://${s3_bucket}/licence.rli /tmp/

# create replicated unattended installer config
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${console_password}",
  "TlsBootstrapType": "self-signed",
  "LogLevel": "debug",
  "ImportSettingsFrom": "/tmp/replicated-settings.json",
  "LicenseFileLocation": "/tmp/licence.rli",
  "BypassPreflightChecks": true
}
EOF
cat > /tmp/replicated-settings.json <<EOF
{
  "hostname": {
    "value": "${hostname}"
  },
  "installation_type": {
    "value": "production"
  },
  "production_type": {
    "value": "external"
  },
  "pg_dbname": {
    "value": "ptfe"
  },
  "pg_extra_params": {
    "value": "sslmode=require"
  },
  "pg_password": {
    "value": "${pg_password}"
  },
  "pg_netloc": {
    "value": "${pg_netloc}"
  },
  "pg_user": {
    "value": "ptfe"
  },
  "aws_instance_profile": {
    "value": "1"
  },
  "s3_bucket": {
    "value": "${s3_bucket}"
  },
  "s3_region": {
    "value": "${s3_region}"
  },
  "disk_path": {
    "value": "/data"
  }
}
EOF

# install replicated
curl https://install.terraform.io/ptfe/beta > /home/ubuntu/install.sh
bash /home/ubuntu/install.sh no-proxy
