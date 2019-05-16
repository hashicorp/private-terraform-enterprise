#!/bin/bash

set -x
exec > /home/ubuntu/install-ptfe.log 2>&1

# Get private and public IPs of the EC2 instance
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PRIVATE_DNS=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

if [ "${public_ip}" == "true" ]; then
  PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
fi

# Write out replicated.conf configuration file
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${ptfe_admin_password}",
  "TlsBootstrapType": "self-signed",
  "ImportSettingsFrom": "/home/ubuntu/ptfe-settings.json",
  "LicenseFileLocation": "/home/ubuntu/ptfe-license.rli",
  "BypassPreflightChecks": true
}
EOF

# Write out PTFE settings file
cat > /home/ubuntu/ptfe-settings.json <<EOF
{
  "hostname": {
    "value": "${hostname}"
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
    "value": "${extra_no_proxy},$PRIVATE_DNS"
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
  },
  "custom_image_tag": {
      "value": "${custom_image_tag}"
  },
  "tbw_image": {
      "value": "${tbw_image}"
  }
}
EOF

# Install the aws CLI
apt-get -y update
apt-get install -y awscli
aws configure set s3.signature_version s3v4

# Set SELinux to permissive
apt install -y selinux-utils
setenforce 0

# Install psql slcient for connecting to PostgreSQL
apt-get install -y postgresql-client

# Create the PTFE database schemas
cat > /home/ubuntu/create_schemas.sql <<EOF
CREATE SCHEMA IF NOT EXISTS rails;
CREATE SCHEMA IF NOT EXISTS vault;
CREATE SCHEMA IF NOT EXISTS registry;
EOF

host=$(echo ${pg_netloc} | cut -d ":" -f 1)
port=$(echo ${pg_netloc} | cut -d ":" -f 2)
PGPASSWORD=${pg_password} psql -h $host -p $port -d ${pg_dbname} -U ${pg_user} -f /home/ubuntu/create_schemas.sql

# Get License File from S3 bucket
aws s3 cp s3://${source_bucket_name}/${ptfe_license} /home/ubuntu/ptfe-license.rli

# Install PTFE
curl https://install.terraform.io/ptfe/stable > /home/ubuntu/install.sh
if [ "${public_ip}" == "true" ]; then
  bash /home/ubuntu/install.sh \
    no-proxy \
    private-address=$PRIVATE_IP \
    public-address=$PUBLIC_IP
else
  bash /home/ubuntu/install.sh \
    no-proxy \
    private-address=$PRIVATE_IP \
    public-address=$PRIVATE_IP
fi

# Allow ubuntu user to use docker
# This will not take effect until after you logout and back in
usermod -aG docker ubuntu

# Check status of install
while ! curl -ksfS --connect-timeout 5 https://$PRIVATE_IP/_health_check; do
    sleep 15
done

# Create initial admin user and organization
# if they don't exist yet
if [ "${create_first_user_and_org}" == "true" ]
then
  echo "Creating initial admin user and organization"
  cat > /home/ubuntu/initialuser.json <<EOF
{
  "username": "${initial_admin_username}",
  "email": "${initial_admin_email}",
  "password": "${initial_admin_password}"
}
EOF

  initial_token=$(replicated admin --tty=0 retrieve-iact)
  iact_result=$(curl --header "Content-Type: application/json" --request POST --data @/home/ubuntu/initialuser.json https://${hostname}/admin/initial-admin-user?token=$${initial_token})
  api_token=$(echo $iact_result | python3 -c "import sys, json; print(json.load(sys.stdin)['token'])")
  echo "API Token of initial admin user is: $api_token"

  # Create first PTFE organization
  cat > /home/ubuntu/initialorg.json <<EOF
{
  "data": {
    "type": "organizations",
    "attributes": {
      "name": "${initial_org_name}",
      "email": "${initial_org_email}"
    }
  }
}
EOF

  org_result=$(curl  --header "Authorization: Bearer $api_token" --header "Content-Type: application/vnd.api+json" --request POST --data @/home/ubuntu/initialorg.json https://${hostname}/api/v2/organizations)
  org_id=$(echo $org_result | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")

fi
