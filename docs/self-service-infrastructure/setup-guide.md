# Training infrastructure setup guide

Follow this guide to provision and validate your own minimal training environment
from the [`infra-template`](https://github.com/cagov/caldata-mdsa-training/tree/main/infra-template).
Every command is copy-paste ready. Placeholders look like `<THIS>` — replace them.

By the end you will have, in a Snowflake account: **1 database, 3 X-Small
warehouses, 3 roles, and a dbt service account**, a green CI pipeline, and a
passing validation run.

## Prerequisites

Install these locally (versions are the minimums this template is tested with):

| Tool        | Version | Install                                                                 |
| ----------- | ------- | ---------------------------------------------------------------------- |
| git         | any     | <https://git-scm.com/downloads>                                        |
| Terraform   | ≥ 1.9   | `brew install terraform` (macOS) / <https://developer.hashicorp.com/terraform/install> |
| tflint      | any     | `brew install tflint`                                                  |
| uv          | ≥ 0.5   | `brew install uv` / `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| GitHub CLI  | any     | `brew install gh` (used to set secrets)                                |
| openssl     | any     | preinstalled on macOS/Linux                                            |

Verify:

```bash
terraform -version && tflint --version && uv --version && gh --version
```

`dbt` itself does **not** need a global install — the template runs it through
`uv run --with dbt-snowflake dbt ...`.

## Administrator-preconfigured items

Before you start, an administrator must have provided (see
[Manual vs. automated](manual-vs-automated.md#administrator-prerequisites-pre-provisioned-done-once-before-learners-begin)):

- A **Snowflake account** you can log into.
- A **Snowflake user for you** with an admin role able to create roles, users, and
  grants — i.e. `SYSADMIN` + `SECURITYADMIN` + `USERADMIN`, or `ACCOUNTADMIN`.
- The **account identifier**: organization name and account name.
- The **GitHub template repository** published as a template.
- The **account session policy applied** — an administrator has run
  `infra-template/scripts/session_policy.sql` once (60-minute idle timeout). The
  Terraform provider does not manage session policies, so this is an admin step.

If you don't have all five, stop and ask your administrator.

## Step 1 — Create a repository from the template

On GitHub, open the template repository and click **Use this template → Create a
new repository**. Then clone your new repo and enter it:

```bash
git clone https://github.com/<YOUR_ORG>/<YOUR_REPO>.git
cd <YOUR_REPO>
```

All remaining commands are run from the repo root, and reference files under
`infra-template/`.

## Step 2 — Set your Snowflake admin credentials

You authenticate to Terraform with **your own admin user** via key-pair auth. If
you don't already have a key pair registered on your Snowflake user, generate one
and register it (once):

```bash
bash infra-template/scripts/generate_key_pair.sh my_admin_key "<A_PASSPHRASE>"
```

Copy the printed single-line public key, then in a Snowsight worksheet run:

```sql
ALTER USER <YOUR_SNOWFLAKE_USER> SET RSA_PUBLIC_KEY='<PASTE_PUBLIC_KEY>';
```

Now set env vars:

```bash
cp infra-template/.env.example infra-template/.env
# edit infra-template/.env: SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER,
# SNOWFLAKE_PRIVATE_KEY_PATH (path to my_admin_key.p8), SNOWFLAKE_PRIVATE_KEY_PASSPHRASE
source infra-template/.env
```

**Expected:** `echo $SNOWFLAKE_ACCOUNT` prints your account, e.g. `MYORG-ABC12345`.

!!! warning
    Make sure no *other* `SNOWFLAKE_*` variables are set — stray ones interfere
    with authentication. Check with `env | grep SNOWFLAKE`.

## Step 3 — Generate the dbt service-account key pair

```bash
cd infra-template
bash scripts/generate_key_pair.sh dbt_svc_dev "<A_DBT_PASSPHRASE>"
```

**Expected output** (abridged):

```
Wrote dbt_svc_dev.p8 (private) and dbt_svc_dev.pub (public).

Single-line public key for terraform.tfvars (dbt_service_account_public_key):
----------------------------------------------------------------------------
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A...   <- copy this whole line
----------------------------------------------------------------------------

For the GitHub secret SNOWFLAKE_PRIVATE_KEY, paste the full contents of dbt_svc_dev.p8.
```

Keep `dbt_svc_dev.p8` — you'll need it for Step 6. (Both key files are git-ignored.)

## Step 4 — Configure Terraform variables

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars`:

```hcl
account_name      = "ABC12345"     # your account name
organization_name = "MYORG"        # your organization name
name_suffix       = "DEV"          # on a shared account, use a unique value (e.g. your initials)
dbt_service_account_public_key = "MIIBIjANBgkqhkiG9w0BAQEF..."  # from Step 3
```

## Step 5 — Provision the infrastructure

```bash
cd terraform
terraform init
terraform apply    # review the plan, then type: yes
cd ..
```

**Expected:** `terraform apply` ends with something like:

```
Apply complete! Resources: 40 added, 0 changed, 0 destroyed.

Outputs:
database_name         = "TRAINING_DEV"
dbt_service_user_name = "DBT_SVC_USER_DEV"
role_names            = ["LOADER_DEV", "TRANSFORMER_DEV", "REPORTER_DEV"]
warehouse_names       = ["LOADING_XS_DEV", "TRANSFORMING_XS_DEV", "REPORTING_XS_DEV"]
```

## Step 6 — Configure GitHub secrets and variables

So CI can run dbt as the service account. From the repo root, authenticated with
`gh auth login`:

```bash
gh variable set SNOWFLAKE_ACCOUNT --body "MYORG-ABC12345"
gh secret set SNOWFLAKE_PRIVATE_KEY < infra-template/dbt_svc_dev.p8
gh secret set SNOWFLAKE_PRIVATE_KEY_PASSPHRASE --body "<A_DBT_PASSPHRASE>"

# Only if you used a non-default name_suffix (e.g. a shared account): tell CI
# which objects to target. Omit this and CI defaults to the DEV suffix.
gh variable set NAME_SUFFIX --body "<YOUR_SUFFIX>"
```

**Expected:** each command confirms the secret or variable was set. Verify with
`gh secret list` and `gh variable list`.

## Step 7 — Local validation

```bash
bash infra-template/scripts/validate.sh
```

**Expected (with credentials set):**

```
==> 1. Terraform format and validation
  PASS  terraform fmt (no formatting changes needed)
  PASS  terraform validate
==> 2. Terraform state and expected objects
  PASS  database output present: TRAINING_DEV
  PASS  3 warehouses in outputs
  PASS  3 functional roles in outputs
==> 3. dbt project structure (offline parse)
  PASS  dbt deps
  PASS  dbt parse (project compiles structurally)
==> 4. dbt compile
  PASS  dbt compile
==> 5. Snowflake connection, objects, and grants
  PASS  dbt debug (connection, database, schema, warehouse, role all reachable)
==> 6. dbt build (seed + models + tests exercise read/write grants)
  PASS  dbt build (grants function: create/insert/select all succeeded)

All checks that ran passed.
```

To run the live dbt checks, point your env at the **service user** first:

```bash
export SNOWFLAKE_USER="DBT_SVC_USER_DEV"
export SNOWFLAKE_PRIVATE_KEY_PATH="$PWD/infra-template/dbt_svc_dev.p8"
export SNOWFLAKE_PRIVATE_KEY_PASSPHRASE="<A_DBT_PASSPHRASE>"
```

## Step 8 — dbt validation on its own

```bash
cd infra-template/transform
export DBT_PROFILES_DIR="$PWD"
uv run --with dbt-snowflake dbt debug     # connection + object checks
uv run --with dbt-snowflake dbt build     # seed + models + tests
cd ../..
```

**Expected:** `dbt debug` prints `All checks passed!`; `dbt build` finishes with
`Completed successfully` and `PASS=... ERROR=0`.

## Step 9 — Trigger GitHub Actions

```bash
git checkout -b setup-validation
git commit --allow-empty -m "Trigger CI"
git push -u origin setup-validation
gh pr create --fill
gh run watch
```

**Expected:** both `terraform-validation` and `ci` (dbt build) complete with green
checks on the PR.

---

## Common setup failures and resolutions

| Symptom                                                                 | Cause                                                            | Fix                                                                                             |
| ---------------------------------------------------------------------- | --------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `terraform apply` → `Error: 390144 ... JWT token is invalid`           | Wrong account identifier, or a stale `SNOWFLAKE_*` env var       | Re-check `account_name`/`organization_name`; run `env \| grep SNOWFLAKE` and unset extras       |
| `apply` → `Insufficient privileges to operate on account`              | Your user lacks `USERADMIN`/`SECURITYADMIN`/`SYSADMIN`           | Ask your admin to grant the admin role (see prerequisites)                                      |
| `apply` → `invalid public key` on the dbt user                         | Public key still has PEM header/trailer or line breaks          | Regenerate with `generate_key_pair.sh`; paste the single-line output exactly                    |
| `dbt debug` → `250001: Could not connect ... JWT`                      | dbt using your admin key instead of the service key             | Set `SNOWFLAKE_USER=DBT_SVC_USER_DEV` and `SNOWFLAKE_PRIVATE_KEY_PATH` to `dbt_svc_dev.p8`      |
| `dbt build` → `Object does not exist or not authorized` (warehouse/db) | Terraform not applied, or wrong env suffix                      | Run `terraform apply`; confirm `DBT_TRAINING_DB`/`SNOWFLAKE_WAREHOUSE` match `name_suffix`      |
| CI `ci` job fails at `dbt build` with an auth error                    | GitHub secrets missing or passphrase wrong                      | Re-run Step 6; confirm `gh secret list` shows `SNOWFLAKE_PRIVATE_KEY[_PASSPHRASE]`              |
| `terraform-validation` CI fails at `fmt`                               | Uncommitted formatting                                          | `terraform -chdir=infra-template/terraform fmt -recursive`, commit                              |
| `Error acquiring the state lock` / `prevent_destroy`                   | Concurrent run / leftover state                                 | Ensure no other apply is running; local state has no lock — just retry                          |

## Cleanup / reset

Reset to a clean environment (repeatable training):

```bash
cd infra-template/terraform
terraform destroy    # type: yes
```

**Expected:** `Destroy complete! Resources: N destroyed.` Re-run
`terraform apply` any time to recreate a fresh environment.

Full teardown (end of training): also delete the GitHub repo (or its Actions
secrets), and if the Snowflake account was training-only, ask your admin to drop
it.

## Done-when

- You can provision, validate, and use the environment following only this guide
  and the documented administrator prerequisites.
