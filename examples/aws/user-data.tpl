#!/bin/bash

# create replicated unattended installer config
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "ptfe-pwd",
  "TlsBootstrapType": "self-signed",
  "LogLevel": "debug",
  "ImportSettingsFrom": "/tmp/replicated-settings.json",
  "LicenseFileLocation": "/tmp/license.rli"
  "BypassPreflightChecks": true
}
EOF
cat > /tmp/replicated-settings.json <<EOF
{
  "hostname": {
    "value": "dan-ptfe-pes.hashidemos.io"
  }
  "installation_type": {
    "value": "production"
  },
  "production_type": {
    "value": "disk"
  },
  "disk_path": {
    "value": "/data"
  },
  "letsencrypt_auto": {
    "value": "1"
  },
  "letsencrypt_email": {
    "value": "null@null.com"
  },
}
EOF

# install replicated
curl https://install.terraform.io/ptfe/beta > /home/ubuntu/install.sh
bash /home/ubuntu/install.sh no-proxy
