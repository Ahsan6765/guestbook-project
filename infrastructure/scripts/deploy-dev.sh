#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
infrastructure_dir="$(cd -- "${script_dir}/.." && pwd)"
dev_dir="${infrastructure_dir}/environments/dev"
firewall_dir="${dev_dir}/mysql-firewall"

for command in terraform jq az; do
  if [[ "${SKIP_DB_MIGRATION:-false}" == "true" && "${command}" == "az" ]]; then
    continue
  fi
  if ! command -v "${command}" >/dev/null 2>&1; then
    echo "Required command not found: ${command}" >&2
    exit 1
  fi
done

terraform -chdir="${dev_dir}" init -input=false
terraform -chdir="${dev_dir}" apply -input=false -auto-approve

outbound_ips="$(terraform -chdir="${dev_dir}" output -json container_app_outbound_ip_addresses)"
if ! jq -e 'type == "array" and length > 0 and all(.[]; type == "string")' <<<"${outbound_ips}" >/dev/null; then
  echo "No Container Apps outbound IPs were returned; refusing to create an open MySQL firewall." >&2
  exit 1
fi

resource_group_name="$(terraform -chdir="${dev_dir}" output -raw resource_group_name)"
mysql_server_name="$(terraform -chdir="${dev_dir}" output -raw mysql_server_name)"
subscription_id="$(terraform -chdir="${dev_dir}" output -raw subscription_id)"
container_app_name="$(terraform -chdir="${dev_dir}" output -raw container_app_name)"

terraform -chdir="${firewall_dir}" init -input=false
terraform -chdir="${firewall_dir}" apply -input=false -auto-approve \
  -var="subscription_id=${subscription_id}" \
  -var="resource_group_name=${resource_group_name}" \
  -var="mysql_server_name=${mysql_server_name}" \
  -var="container_app_egress_ips=${outbound_ips}"

if [[ "${SKIP_DB_MIGRATION:-false}" == "true" ]]; then
  echo "Firewall rules are synchronized. Database migration was skipped by request."
  exit 0
fi

az account set --subscription "${subscription_id}"

for attempt in {1..30}; do
  running_replicas="$(az containerapp replica list \
    --subscription "${subscription_id}" \
    --resource-group "${resource_group_name}" \
    --name "${container_app_name}" \
    --query "length([?properties.runningState=='Running'])" \
    --output tsv 2>/dev/null || true)"

  if [[ "${running_replicas:-0}" -gt 0 ]]; then
    break
  fi

  if [[ "${attempt}" -eq 30 ]]; then
    echo "Container App has no running replicas after waiting; refusing to run migration." >&2
    exit 1
  fi

  echo "Waiting for a running Container App replica (${attempt}/30)..."
  sleep 10
done

az containerapp exec \
  --subscription "${subscription_id}" \
  --resource-group "${resource_group_name}" \
  --name "${container_app_name}" \
  --command "npm run db:migrate"
