#!/bin/bash

set -x
exec > /home/ec2-user/install-ptfe.log 2>&1

# Get private and public IPs of the EC2 instance
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
PRIVATE_DNS=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
PUBLIC_IP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)

# Write out replicated.conf configuration file
cat > /etc/replicated.conf <<EOF
{
  "DaemonAuthenticationType": "password",
  "DaemonAuthenticationPassword": "${ptfe_admin_password}",
  "TlsBootstrapType": "self-signed",
  "ImportSettingsFrom": "/home/ec2-user/ptfe-settings.json",
  "LicenseFileLocation": "/home/ec2-user/ptfe-license.rli",
  "LicenseBootstrapAirgapPackagePath": "/home/ec2-user/${airgap_bundle}",
  "BypassPreflightChecks": true
}
EOF

# Write out PTFE settings file
cat > /home/ec2-user/ptfe-settings.json <<EOF
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

# Create the PTFE database schemas
cat > /home/ec2-user/create_schemas.sql <<EOF
CREATE SCHEMA IF NOT EXISTS rails;
CREATE SCHEMA IF NOT EXISTS vault;
CREATE SCHEMA IF NOT EXISTS registry;
EOF

host=$(echo ${pg_netloc} | cut -d ":" -f 1)
port=$(echo ${pg_netloc} | cut -d ":" -f 2)
PGPASSWORD=${pg_password} psql -h $host -p $port -d ${pg_dbname} -U ${pg_user} -f /home/ec2-user/create_schemas.sql

# Get License File from S3 bucket
aws s3 cp s3://${source_bucket_name}/${ptfe_license} /home/ec2-user/ptfe-license.rli

# Download the Airgap bundle
aws s3 cp s3://${source_bucket_name}/${airgap_bundle} /home/ec2-user/${airgap_bundle}

# Download and extract the Replicated Bootstrapper
aws s3 cp s3://${source_bucket_name}/${replicated_bootstrapper} /home/ec2-user/${replicated_bootstrapper}
mkdir /opt/ptfe-installer
cp /home/ec2-user/${replicated_bootstrapper} /opt/ptfe-installer/.
tar xzf /opt/ptfe-installer/${replicated_bootstrapper} -C /opt/ptfe-installer

# Install PTFE
cd /opt/ptfe-installer
./install.sh \
  airgap \
  no-proxy \
  private-address=$PRIVATE_IP\
  public-address=$PUBLIC_IP

# Check status of install
while ! curl -ksfS --connect-timeout 5 https://${hostname}/_health_check; do
    sleep 15
done

# Create initial admin user and organization
# if they don't exist yet
if [ "${create_first_user_and_org}" == "true" ]
then
  echo "Creating initial admin user and organization"
  cat > /home/ec2-user/initialuser.json <<EOF
{
  "username": "${initial_admin_username}",
  "email": "${initial_admin_email}",
  "password": "${initial_admin_password}"
}
EOF

  initial_token=$(replicated admin --tty=0 retrieve-iact)
  iact_result=$(curl --header "Content-Type: application/json" --request POST --data @/home/ec2-user/initialuser.json "https://${hostname}/admin/initial-admin-user?token=$${initial_token}")
  api_token=$(echo $iact_result | python -c "import sys, json; print(json.load(sys.stdin)['token'])")
  echo "API Token of initial admin user is: $api_token"

  # Create first PTFE organization
  cat > /home/ec2-user/initialorg.json <<EOF
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

  org_result=$(curl  --header "Authorization: Bearer $api_token" --header "Content-Type: application/vnd.api+json" --request POST --data @/home/ec2-user/initialorg.json "https://${hostname}/api/v2/organizations")
  org_id=$(echo $org_result | python -c "import sys, json; print(json.load(sys.stdin)['data']['id'])")

fi
