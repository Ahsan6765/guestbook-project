#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
infrastructure_dir="$(cd -- "${script_dir}/.." && pwd)"
dev_dir="${infrastructure_dir}/environments/dev"
firewall_dir="${dev_dir}/mysql-firewall"

for command in terraform jq; do
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Required command not found: ${command}" >&2
    exit 1
  fi
done

if [[ "${SKIP_DB_MIGRATION:-false}" != "true" ]] && ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required to run the migration in Container Apps. Set SKIP_DB_MIGRATION=true to skip it." >&2
  exit 1
fi

# First apply the regular stack. Firewall rules are intentionally owned by the
# separate root because ACA egress IPs are only known after the app exists.
terraform -chdir="${dev_dir}" apply

outbound_ips="$(terraform -chdir="${dev_dir}" output -json container_app_outbound_ip_addresses)"
if ! jq -e 'type == "array" and length > 0 and all(.[]; type == "string")' <<<"${outbound_ips}" >/dev/null; then
  echo "No Container Apps outbound IPs were returned; refusing to create an open MySQL firewall." >&2
  exit 1
fi

resource_group_name="$(terraform -chdir="${dev_dir}" output -raw resource_group_name)"
mysql_server_name="$(terraform -chdir="${dev_dir}" output -raw mysql_server_name)"
subscription_id="$(terraform -chdir="${dev_dir}" output -raw subscription_id)"
container_app_name="$(terraform -chdir="${dev_dir}" output -raw container_app_name)"

# This small state applies only the MySQL firewall rules. It does not reapply
# the full infrastructure and will remove stale ACA egress addresses.
terraform -chdir="${firewall_dir}" init -input=false
terraform -chdir="${firewall_dir}" apply \
  -input=false \
  -var="subscription_id=${subscription_id}" \
  -var="resource_group_name=${resource_group_name}" \
  -var="mysql_server_name=${mysql_server_name}" \
  -var="container_app_egress_ips=${outbound_ips}"

if [[ "${SKIP_DB_MIGRATION:-false}" == "true" ]]; then
  echo "Firewall rules are synchronized. Database migration was skipped by request."
  exit 0
fi

# Execute the idempotent schema migration from inside the Container App so its
# connection uses the same ACA egress path that was just allowlisted.
az containerapp exec \
  --resource-group "${resource_group_name}" \
  --name "${container_app_name}" \
  --command "npm run db:migrate"
