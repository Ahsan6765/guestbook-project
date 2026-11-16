# Development infrastructure workflow

The dev environment uses public service endpoints and public Container Apps ingress. Its delegated VNet subnet supports Container Apps integration; this does not create Private Endpoints or private DNS. No Private Endpoints, private DNS zones, or NAT Gateway are provisioned. ACR and Key Vault use managed identity/RBAC. MySQL accepts connections only from the current Container Apps outbound IPv4 addresses.

Log Analytics and platform diagnostic settings are intentionally not provisioned during this test phase. Container Apps logs are streamed only; they are not retained in a workspace. The reusable `modules/log-analytics` module remains available for a later observability change. To enable centralized logs later, add that module back to the dev root and configure the Container Apps environment's `logs_destination` as `log-analytics` with its workspace ID.

## First-time Terraform state setup

The dev backend in `environments/dev/backend.tf` expects the public Azure Blob Storage endpoint for `stmyappdev`, resource group `rg-tfstate-myapp-dev`, and container `tfstate`. These must exist before running `terraform init` in the dev directory. On a fresh subscription, first run `terraform init` and `terraform apply` from `bootstrap/` using local state; then initialize the dev backend. The bootstrap creates a normal public Storage endpoint; it does not create a Private Endpoint or private DNS zone. The identity running dev Terraform also needs `Storage Blob Data Contributor` on the state account/container.

If `terraform init` reports `lookup <account>.blob.core.windows.net: no such host`, that is a DNS resolution failure before Terraform can authenticate or inspect the container. Confirm the storage account name is correct and the bootstrap completed in the expected subscription. If the account exists, check that the machine's configured DNS resolver can resolve public Azure Storage hostnames and that outbound DNS/HTTPS is permitted. No private DNS configuration should be added for this public-endpoint design.

## Deploy, synchronize firewall, and migrate

Prerequisites: Terraform, Azure CLI signed into the target subscription, access to the configured remote Terraform state, and a backend image containing this repository's migration script.

From the repository root, run:

```sh
bash infrastructure/scripts/deploy-dev.sh
```

The helper performs these steps in order:

1. Applies the dev infrastructure root.
2. Reads the deployed Container App's current outbound IP list from Terraform outputs.
3. Applies only the dedicated `mysql-firewall` Terraform root, reconciling per-IP MySQL firewall rules. No manual IP copy or second full infrastructure apply is needed.
4. Runs `npm run db:migrate` inside the Container App, after its egress is allowlisted.

For an infrastructure-only deployment before the new backend image is published, set `SKIP_DB_MIGRATION=true`; the placeholder image does not contain the migration command. When using automation, Terraform's usual `TF_CLI_ARGS_apply=-auto-approve` environment setting can disable interactive approval for both applies.

The firewall root has its own remote state key (`dev/mysql-firewall.tfstate`). Keep that state: it exclusively owns the generated MySQL firewall rules. Use this helper for future deployments so changed ACA egress IPs are reconciled and stale rules removed. Without NAT, ACA outbound IPs may change; a direct `terraform apply` of only the dev root will not synchronize firewall rules.

## Database contract

Terraform injects `DB_HOST`, `DB_PORT`, `DB_NAME`, and `PORT` as ordinary app settings and references the MySQL username/password from Key Vault as `DB_USER` and `DB_PASSWORD`. `DB_SSL=true` is set for Azure MySQL; Docker Compose uses `DB_SSL=false` for local MySQL.

Terraform creates the `guestbook_db` database. `app/database/schema.sql` contains an idempotent table migration. `npm run db:migrate` applies that schema. It is also mounted as the MySQL container's initialization script for a fresh local Compose volume.

The current dev database username is the MySQL server administrator account. This is acceptable only as a temporary development setup; use a distinct least-privilege app user before production.
