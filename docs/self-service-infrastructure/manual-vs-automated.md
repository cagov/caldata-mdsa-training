# Manual vs. Automated: the self-service boundary

This document finalizes the **self-service boundary** for the training
infrastructure: which setup steps must remain manual, and which are automated,
scripted, templated, or pre-provisioned so that learners can provision their own
training environment with minimal effort.

It is the decision record behind the
[minimal infrastructure design](design.md) and the
[setup guide](setup-guide.md).

## Classification scheme

Every setup step is classified as one of:

| Class              | Meaning                                                                                  |
| ------------------ | ---------------------------------------------------------------------------------------- |
| **Manual**         | A human must perform it in a UI or console; it cannot be safely or reasonably automated. |
| **Scripted**       | Automated by a script in the template (`scripts/`) that the learner runs.                |
| **Templated**      | Provided as ready-to-use files in the template (Terraform, dbt, workflows, config).      |
| **Pre-Provisioned**| Done once by an administrator before any learner starts; learners inherit the result.    |

## The simplified training architecture (recommended baseline)

Training uses a deliberately **smaller** architecture than production. The
production `data-infrastructure` repository provisions three databases
(`RAW`/`TRANSFORM`/`ANALYTICS`), warehouses in all eight sizes, five functional
roles, and multiple service accounts (Fivetran, Airflow, dbt Cloud, GitHub CI)
across `dev` and `prd`, with S3 remote state.

For training we collapse that to the minimum that still teaches role-based access
control and an end-to-end ELT flow:

| Component      | Production                                        | **Training (this template)**                          |
| -------------- | ------------------------------------------------- | ----------------------------------------------------- |
| Databases      | 3 (`RAW`, `TRANSFORM`, `ANALYTICS`) × 2 envs      | **1** (`TRAINING_DEV`, schemas `raw`/`staging`/`marts`) |
| Warehouse sizes| 8 sizes × 3 functions                             | **3** X-Small warehouses (load, transform, report)    |
| Functional roles | 5 (loader, transformer, reporter, reader, streamlit) | **3** (loader, transformer, reporter)          |
| Service accounts | Fivetran, Airflow, dbt Cloud, GitHub CI         | **1** dbt service account                             |
| Environments   | `dev` + `prd`                                      | **1** (`DEV`)                                          |
| Terraform state| S3 + DynamoDB lock                                | **local state** (no cloud prerequisites)              |
| Auth           | Key-pair (keys in 1Password)                      | Key-pair (learner-generated, GitHub secret)           |

**This simplified architecture is the recommended baseline for all training.**
Learners should not attempt to reproduce the full production architecture; it
adds cost, cloud prerequisites, and cognitive load without adding learning value.

## Manual-step taxonomy

The production setup has several steps that cannot be fully self-served because of
access restrictions, security requirements, or intentional design constraints. The
table records each one, why it is manual, how the training template resolves it, and
its training impact (HIGH / MEDIUM / LOW).

| # | Step                          | Reason it is manual                              | Training template resolution                                                       | Impact |
| - | ----------------------------- | ------------------------------------------------ | --------------------------------------------------------------------------------- | ------ |
| 1 | Snowflake account creation    | Requires `ORGADMIN` at the org level             | Pre-provisioned once by an admin; learners reuse the account with a per-learner `name_suffix` | HIGH   |
| 2 | Snowflake MFA enrollment      | Requires a user-specific device (e.g. Duo)       | Learner self-enrolls once; cannot be automated, but low complexity                 | MEDIUM |
| 3 | Session policy application    | Not supported by the Terraform provider          | Provided as `scripts/session_policy.sql`; an admin runs it once                    | LOW    |
| 4 | Cross-environment role grants | Intentionally manual to preserve env isolation   | Not applicable — training uses a single `name_suffix`, so there are no cross-env grants | MEDIUM |
| 5 | AWS account/state access      | Governed by org security/access policy           | **Eliminated** — the template uses local Terraform state, so no S3/AWS is required | HIGH   |
| 6 | GitHub org/repo creation      | Requires org-level admin privileges              | Pre-provisioned template repo; learner clicks "Use this template"                  | MEDIUM |
| 7 | dbt Cloud project setup       | Requires dbt Cloud admin access                  | **Eliminated** — the template uses dbt Core via `uv`, so no dbt Cloud is required  | MEDIUM |

**Net effect on the two HIGH blockers.** AWS access (#5) and dbt Cloud (#7) are
removed entirely by the training template's design (local state + dbt Core). Only
Snowflake account creation (#1) remains, and it is a one-time administrator
prerequisite rather than a per-learner blocker. Everything else is low-friction or
pre-provisioned.

## Step-by-step classification

### Administrator prerequisites (Pre-Provisioned — done once, before learners begin)

These are the **only** things an administrator must do before a learner can
self-serve. They are documented for admins and assumed by the learner guide.

| Step                                                                 | Class            | Rationale                                                                                             |
| -------------------------------------------------------------------- | ---------------- | ---------------------------------------------------------------------------------------------------- |
| Create the Snowflake account (or dedicated training account)         | Pre-Provisioned  | **Governance / cost.** Account creation requires `ORGADMIN` and has billing implications; not learner-safe. |
| Grant the learner a Snowflake user with an admin role (`SYSADMIN` + `SECURITYADMIN` + `USERADMIN`, or `ACCOUNTADMIN`) | Pre-Provisioned | **Security.** Terraform must create roles/grants; only an admin can delegate this. |
| Enable MFA and apply the session policy (`scripts/session_policy.sql`)| Pre-Provisioned  | **Security / org policy.** Account-level security posture is an admin responsibility; the session policy is provided as a ready-to-run script. |
| Provide the account identifier (org name + account name)             | Pre-Provisioned  | Learner needs it for `terraform.tfvars`; trivially shared.                                            |
| Create the template GitHub repository (mark as a template repo)      | Pre-Provisioned  | Enables learners to click "Use this template"; done once by the org.                                  |

### Learner setup steps

| Step                                                        | Class     | Rationale / how learner effort is minimized                                                                   |
| ----------------------------------------------------------- | --------- | ------------------------------------------------------------------------------------------------------------ |
| Create a repo from the template                             | Manual    | **Technical limitation.** Requires a human click ("Use this template") tied to the learner's GitHub account. Minimized: one click, no configuration. |
| Install local tooling (terraform, uv, git)                  | Manual    | **Technical limitation.** Local machine setup can't be done for the learner. Minimized: exact copy-paste commands + version pins in the guide. |
| Set Snowflake credentials as env vars                       | Templated | `.env.example` provided; learner copies to `.env` and fills 4 values, then `source .env`.                     |
| Generate the dbt service-account key pair                   | Scripted  | `scripts/generate_key_pair.sh` creates the key pair and prints the exact one-line public key to paste.        |
| Fill in Terraform variables                                 | Templated | `terraform.tfvars.example` lists every value with inline guidance; learner copies and edits.                  |
| Write the Terraform for DB/warehouses/roles/user            | Templated | Fully provided under `terraform/`. Learner writes **no HCL**.                                                 |
| Provision the infrastructure                                | Scripted  | `terraform init && terraform apply` — two standard commands, documented verbatim.                             |
| Register the dbt public key on the service user             | Templated | Automated: the public key is passed to Terraform (`dbt_service_account_public_key`), so no manual `ALTER USER`. |
| Configure GitHub secrets/vars for CI                        | Manual    | **Security.** Secrets must be entered in the GitHub UI (or `gh secret set`); the values (private key, passphrase, account) can't be committed. Minimized: exact `gh` CLI commands provided. |
| GitHub Actions workflows (terraform-validation, dbt build)  | Templated | Provided under `.github/workflows/`; run automatically on push/PR.                                            |
| dbt profile                                                 | Templated | `transform/profiles.yml` uses env vars; works locally and in CI unchanged.                                    |
| Validate the environment                                    | Scripted  | `bash scripts/validate.sh` — one command, PASS/FAIL per check.                                                |
| Cleanup / reset                                             | Scripted  | `terraform destroy` (documented) tears the environment down for a repeatable reset.                           |

### Why each remaining manual step cannot be automated

Only three learner steps stay manual, each for a concrete reason:

1. **Creating a repo from the template** — GitHub requires an authenticated human
   action tied to the learner's own account; there is no safe way to do it on the
   learner's behalf. *(Technical limitation.)*
2. **Installing local tooling** — runs on the learner's own machine, outside any
   automation we control. *(Technical limitation.)* We minimize effort with exact,
   OS-specific commands and pinned versions.
3. **Setting GitHub Actions secrets** — secret material (the private key and its
   passphrase) must never be committed to the repository, so it must be entered
   through the GitHub UI or `gh` CLI by the learner. *(Security requirement.)* We
   minimize effort by providing the exact `gh secret set` / `gh variable set`
   commands.

Everything else is templated, scripted, or pre-provisioned.

## Decision matrix: administrator vs. learner responsibilities

| Responsibility                                   | Administrator | Learner |
| ------------------------------------------------ | :-----------: | :-----: |
| Create/own the Snowflake account                 |       Yes       |         |
| Grant admin roles to the learner's Snowflake user|       Yes       |         |
| Enable MFA + session policy on the account       |       Yes       |         |
| Provide account identifier to learners           |       Yes       |         |
| Publish the GitHub template repository           |       Yes       |         |
| Create a repo from the template                  |               |    Yes    |
| Install local tooling                            |               |    Yes    |
| Generate the dbt key pair                        |               |    Yes    |
| Fill in `terraform.tfvars` / `.env`              |               |    Yes    |
| Run `terraform apply`                            |               |    Yes    |
| Configure GitHub secrets/vars                    |               |    Yes    |
| Run `scripts/validate.sh`                        |               |    Yes    |
| Tear down / reset with `terraform destroy`       |               |    Yes    |

## Done-when

- The self-service boundary is finalized (table above).
- The simplified training architecture is documented as the recommended baseline.
- Every step is classified Manual / Scripted / Templated / Pre-Provisioned with rationale.
- Administrator prerequisites are enumerated.
- A decision matrix defines administrator vs. learner responsibilities.
