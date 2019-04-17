#!/bin/bash

set -x
exec > /home/ubuntu/install-ptfe.log 2>&1

# Get private and public IPs of the EC2 instance
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Write out replicated.conf configuration file
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${ptfe_admin_password}",
  "TlsBootstrapType": "self-signed",
  "ImportSettingsFrom": "/tmp/ptfe-settings.json",
  "LicenseFileLocation": "/tmp/ptfe-license.rli",
  "BypassPreflightChecks": true
}
EOF

# Write out PTFE settings file
cat > /tmp/ptfe-settings.json <<EOF
{
  "hostname": {
    "value": "$PUBLIC_IP"
  },
  "ca_certs": {
    "value": "${ca_certs}"
  },
  "installation_type": {
    "value": "${installation_type}"
  },
  "production_type": {
    "value": "${production_type}"
  },
  "capacity_concurrency": {
    "value": "${capacity_concurrency}"
  },
  "capacity_memory": {
    "value": "${capacity_memory}"
  },
  "enc_password": {
    "value": "${enc_password}"
  },
  "enable_metrics_collection": {
    "value": "${enable_metrics_collection}"
  },
  "extra_no_proxy": {
    "value": "${extra_no_proxy}"
  },
  "pg_dbname": {
    "value": "${pg_dbname}"
  },
  "pg_extra_params": {
    "value": "${pg_extra_params}"
  },
  "pg_netloc": {
    "value": "${pg_netloc}"
  },
  "pg_password": {
    "value": "${pg_password}"
  },
  "pg_user": {
    "value": "${pg_user}"
  },
  "placement": {
    "value": "${placement}"
  },
  "aws_instance_profile": {
    "value": "${aws_instance_profile}"
  },
  "s3_bucket": {
    "value": "${s3_bucket}"
  },
  "s3_region": {
    "value": "${s3_region}"
  },
  "s3_sse": {
    "value": "${s3_sse}"
  },
  "s3_sse_kms_key_id": {
    "value": "${s3_sse_kms_key_id}"
  },
  "vault_path": {
    "value": "${vault_path}"
  },
  "vault_store_snapshot": {
    "value": "${vault_store_snapshot}"
  }
}
EOF

# Get License File from S3 bucket
apt-get -y update
apt-get install -y awscli
aws configure set s3.signature_version s3v4
aws s3 cp s3://${source_bucket_name}/${ptfe_license} /tmp/ptfe-license.rli

# Set SELinux to permissive
apt install -y selinux-utils
setenforce 0

# Disable ufw
ufw allow in on docker0

# Create database schemas
apt-get install -y postgresql-client

cat > /home/ubuntu/create_schemas.sql <<EOF
CREATE SCHEMA IF NOT EXISTS rails;
CREATE SCHEMA IF NOT EXISTS vault;
CREATE SCHEMA IF NOT EXISTS registry;
EOF

host=$(echo ${pg_netloc} | cut -d ":" -f 1)
port=$(echo ${pg_netloc} | cut -d ":" -f 2)
PGPASSWORD=${pg_password} psql -h $host -p $port -d ${pg_dbname} -U ${pg_user} -f /home/ubuntu/create_schemas.sql

# Install PTFE
curl https://install.terraform.io/ptfe/stable > /home/ubuntu/install.sh

bash /home/ubuntu/install.sh \
  no-proxy \
  private-address=$PRIVATE_IP\
  public-address=$PUBLIC_IP

usermod -aG docker ubuntu
