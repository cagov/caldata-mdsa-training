# Self-Service Training Infrastructure Template

A stripped-down, self-service version of the CalData
[data-infrastructure](https://github.com/cagov/data-infrastructure) Snowflake +
dbt setup, designed so a learner can provision a working training environment on
their own with only a few administrator prerequisites.

## What it provisions

The **simplified training architecture**:

- **1 Snowflake database** — `TRAINING_<ENV>` (schemas: `raw`, `staging`, `marts`)
- **3 X-Small warehouses** — `LOADING_XS_<ENV>`, `TRANSFORMING_XS_<ENV>`, `REPORTING_XS_<ENV>`
- **3 functional roles** — `LOADER_<ENV>`, `TRANSFORMER_<ENV>`, `REPORTER_<ENV>`
- **1 dbt service account** — `DBT_SVC_USER_<ENV>` (key-pair authentication)

## Layout

```
infra-template/
├── terraform/           # Terraform for the simplified architecture (local state)
│   ├── main.tf          # providers + module wiring
│   ├── variables.tf outputs.tf terraform.tfvars.example
│   └── modules/{database,warehouse,training}/
├── transform/           # minimal dbt project (seed + staging + mart + tests)
├── scripts/
│   ├── generate_key_pair.sh   # make the dbt service-account key pair
│   ├── validate.sh            # one-command environment validation
│   └── validate.sql           # manual Snowflake object/grant checks
├── .github/workflows/   # terraform-validation.yml, ci.yml (dbt build)
└── .env.example
```

## Quick start

See the full [setup guide](../docs/self-service-infrastructure/setup-guide.md).
In short:

```bash
cp .env.example .env && source .env          # admin Snowflake credentials
cp terraform/terraform.tfvars.example terraform/terraform.tfvars   # edit values

bash scripts/generate_key_pair.sh dbt_svc_dev   # generate dbt key pair
# paste the printed public key into terraform.tfvars

cd terraform && terraform init && terraform apply && cd ..
bash scripts/validate.sh                      # verify everything works
```

## Validation

`bash scripts/validate.sh` checks, with a clear PASS/FAIL per step:

1. Terraform is formatted and valid.
2. Terraform outputs report the expected 1 database / 3 warehouses / 3 roles.
3. The dbt project parses.
4. `dbt debug` — connection, database, schema, warehouse, and role all reachable.
5. `dbt build` — seed + models + tests, exercising the read/write grants end to end.

Steps 4–5 are skipped (not failed) when Snowflake credentials are not present, so
the same script works locally and in CI.
