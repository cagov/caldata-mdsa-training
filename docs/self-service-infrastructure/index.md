# Self-service training infrastructure

## Purpose

This section lets a learning team **provision their own Snowflake + dbt training
environment** with minimal effort and only a few administrator prerequisites. It
is a deliberately stripped-down version of CalData's production
[data-infrastructure](https://github.com/cagov/data-infrastructure), sized for
learning rather than production workloads.

Use it when your team wants a real, working environment to practice the dbt and
Snowflake portions of this training without a hands-on setup session.

## Prerequisites

**For learners** (local machine): `git`, `terraform` (≥ 1.9), `tflint`, `uv`, the
GitHub CLI (`gh`), and `openssl`. See the
[setup guide](setup-guide.md#prerequisites) for install commands.

**From your administrator** (done once): a Snowflake account, a Snowflake user for
you with an admin role, the account identifier, and access to the GitHub template
repository. Full list:
[administrator prerequisites](manual-vs-automated.md#administrator-prerequisites-pre-provisioned-done-once-before-learners-begin).

## Overview of the minimal training architecture

| Component        | What you get                                              |
| ---------------- | -------------------------------------------------------- |
| Database         | **1** — `TRAINING_DEV` (schemas `raw`, `staging`, `marts`) |
| Warehouses       | **3** X-Small — load, transform, report                   |
| Functional roles | **3** — loader, transformer, reporter                     |
| Service account  | **1** — `DBT_SVC_USER_DEV` (key-pair auth)                |

This is intentionally smaller than production (which has three databases, five
roles, and many warehouse sizes). Full rationale and comparison:
[the simplified training architecture](manual-vs-automated.md#the-simplified-training-architecture-recommended-baseline).

## Manual vs. automated responsibilities

Almost everything is templated or scripted. Only three learner steps stay manual —
creating the repo from the template, installing local tooling, and setting GitHub
secrets — each for a documented technical or security reason. See the
[decision matrix](manual-vs-automated.md#decision-matrix-administrator-vs-learner-responsibilities).

## Resources

- **[Infrastructure design](design.md)** — the complete specification of the
  minimal training infrastructure.
- **[Infrastructure template](https://github.com/cagov/caldata-mdsa-training/tree/main/infra-template)** —
  the Terraform, dbt project, scripts, and GitHub Actions you provision from.
- **[Setup guide](setup-guide.md)** — step-by-step, copy-paste instructions from a
  new repository to a validated environment.
- **[Manual vs. automated boundary](manual-vs-automated.md)** — the decision record
  and administrator/learner responsibility matrix.

## Validation

After provisioning, run one command:

```bash
bash infra-template/scripts/validate.sh
```

It checks, with a clear PASS/FAIL for each: Terraform format/validity, the expected
1 database / 3 warehouses / 3 roles, dbt project structure, the live Snowflake
connection and grants (`dbt debug`), and an end-to-end `dbt build`. See
[the validation process](design.md#8-environment-validation-process) for details
and [the setup guide](setup-guide.md#step-7-local-validation) for expected output.

## Troubleshooting

Common failures and fixes are collected in the
[setup guide troubleshooting table](setup-guide.md#common-setup-failures-and-resolutions)
— authentication errors, missing privileges, malformed public keys, and CI secret
problems. To reset to a clean state at any time, use
[cleanup/reset](setup-guide.md#cleanup-reset) (`terraform destroy`).
