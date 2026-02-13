# Continuous Integration/Continuous Deployment

!!! tip "Hands-On Learning"
    This page provides conceptual overview of CI/CD. For hands-on exercises where you'll actually build GitHub Actions workflows and configure CI/CD pipelines, see **[CI/CD Hands-On Workshop](ci-cd-hands-on.md)**.

Continuous Integration and Continuous Deployment (or Delivery), usually abbreviated as CI/CD,
are a critical part of modern software, data, and analytics engineering.
Broadly speaking, they are about automating parts of the code development process:

* **Continuous Integration (CI)** refers to automating testing, linters, formatters, and other code quality checks.
* **Continuous Deployment (CD)** refers to automating build, deployment, or publishing processes.
    This could happen on every merge to `main`, or could be triggered by specific actions in special repository branches.

Automating things using CI/CD provides major benefits to development teams:

1. Catch bugs and other errors before they are deployed
1. Develop new features with speed and confidence
1. Establish a house style with linters and formatters
1. Remove humans from complex and error-prone deployment processes

## Continuous Integration (CI)

Most developers interact with CI checks on a daily basis.
Usually CI checks run on every proposed change to the code base (i.e., pull requests to `main`).
Examples of CI checks include:

- **Code quality checks:** These look for issues with your code, such as syntax errors, potential security vulnerabilities, and performance issues.
- **Build checks:** These ensure your code can be successfully built.
- **Test checks:** These run your unit tests and integration tests to ensure that they pass.
- **Deployment checks:** These ensure your code can be successfully deployed to a test environment.

ODI's MDSA projects usually use a combination of
dbt Platform (setup instructions [here](https://cagov.github.io/data-infrastructure/setup/dbt-setup/))
and GitHub Actions (setup instructions [here](https://cagov.github.io/data-infrastructure/setup/repo-setup/#set-up-ci-in-github))
for running CI. We include the following CI checks:

#### pre-commit

The pre-commit check is a collection of smaller checks.
They are intended to be fast and cheap to run,
so the entire suite runs in a couple of seconds or less.

ODI's MDSA projects typically contains (at least) the following pre-commit checks:

* Verifying that `.json` files are valid
* Verifying that `.yaml` files are valid
* Trimming whitespace from the end of lines and files
* Checking that merge conflicts aren't committed
* Type checking, linting, and formatting Python files using `ruff` and `mypy`
    (for projects that include Python)
* Linting and formatting SQL files using `sqlfluff`
* Linting and formatting YAML files using `prettier` and `yamllint`.

These checks run in two different contexts:

1. They are run for the whole project on every pull request to `main` in CI.
1. Since they are fast and cheap, they can be installed as git
    [pre-commit hooks](https://git-scm.com/book/ms/v2/Customizing-Git-Git-Hooks) (hence the name of the check).
    For instructions on how to install pre-commit hooks locally see
    [these docs](local-dev-setup.md#5-install-pre-commit-hooks).

#### dbt build

The dbt build check builds the dbt project in the development environment.
Depending on the scale of the data, this build might take a significant amount of time,
and may cost some money in Snowflake compute (as such it isn't appropriate for a pre-commit check).
Building a dbt project includes the following components:

* Verifies that models can build
* Verifies that data tests pass
* Verifies that seed load

The ODI team currently uses two different approaches to running this CI check:

1. Run using [dbt Platform's continuous integration hooks](https://docs.getdbt.com/docs/deploy/continuous-integration)
1. Run using GitHub Aactions or Bitbucket Pipelines (example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/tests.yml))

In both cases, a service account is used to connect to Snowflake when running the check.
The schemas for models built during CI are given a prefix to indicate the source of the build,
such as `DBT_CLOUD_PR_` or `GH_CI_PR_`, or `BITBUCKET_CI_`.

#### docs build

The docs build check ensures that the project docs build without issue
(example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/docs.yml)).

## Continuous Deployment (CD)

Continuous Deployment (CD) in most MDSA projects is usually pretty simple.
We typically do not build any applications or deploy cloud resources.
Instead, whatever is in the `main` branch is considered "production",
and our dbt projects and docs are built using that.

ODI's MDSA projects usually include the following CD processes:

#### dbt build

The dbt build step checks out the `main` branch of the project repository
and builds the dbt project in the production environment.

The ODI team currently uses two different approaches to running this process:

1. Run using a dbt Platform production environment
1. Run using CI systems like GitHub Actions or Bitbucket Pipelines (example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/pipeline.yml))

#### docs build

The docs build step checks out the `main` branch of the project repository,
builds the HTML project docs, and pushes them to GitHub Pages
(example [here](https://github.com/cagov/caldata-ddrc-pipelines/blob/main/.github/workflows/docs.yml)).

In most cases our docs CI check is the same as our docs CD process,
the CI check just skips the push to GitHub pages.

# CI/CD Hands-On Workshop

## Overview

This workshop provides hands-on exercises to set up Continuous Integration and Continuous Deployment (CI/CD) for your dbt project using GitHub Actions.

**Prerequisites:**
- Completed [Local Repo Setup](local-dev-setup.md)
- GitHub repository with dbt project
- Snowflake service account credentials
- Basic understanding of [CI/CD Concepts](ci-cd.md)

**What You'll Build:**
- GitHub Actions workflow for automated testing
- dbt build integration in CI pipeline
- Secret management for Snowflake credentials
- Debug and troubleshoot CI failures

**Time:** 2-3 hours

---

## Exercise 1: Create Basic GitHub Actions Workflow

### Step 1: Understand GitHub Actions Structure

GitHub Actions workflows are YAML files stored in `.github/workflows/` directory.

**Basic structure:**
```yaml
name: Workflow Name
on: [trigger events]
jobs:
  job-name:
    runs-on: ubuntu-latest
    steps:
      - name: Step description
        uses: action@version
```

### Step 2: Create Pre-commit Workflow

Create `.github/workflows/pre-commit.yml`:

```yaml
name: pre-commit

on:
  pull_request:
  push:
    branches: [main]

jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true

      - name: Set up Python
        run: uv python install

      - name: Run pre-commit
        uses: pre-commit/action@v3.0.1
```

**What this does:**
- Triggers on PRs and pushes to main
- Checks out your code
- Installs Python dependencies
- Runs all pre-commit hooks

### Step 3: Test the Workflow

1. Commit the workflow file:
   ```bash
   git add .github/workflows/pre-commit.yml
   git commit -m "Add pre-commit CI workflow"
   git push
   ```

2. Create a test PR to verify it runs

3. Check the "Actions" tab in GitHub to see results

**Success criteria:** Green checkmark on your PR

---

## Exercise 2: Add dbt Build to CI

### Step 1: Create dbt CI Workflow

Create `.github/workflows/dbt-ci.yml`:

```yaml
name: dbt CI

on:
  pull_request:

jobs:
  dbt-build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true

      - name: Set up Python
        run: uv python install

      - name: Install dbt
        run: uv sync

      - name: Run dbt debug
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
          SNOWFLAKE_ROLE: TRANSFORMER_DEV
          SNOWFLAKE_WAREHOUSE: TRANSFORMING_XS_DEV
          SNOWFLAKE_DATABASE: TRANSFORM_DEV
        run: |
          uv run dbt debug --profiles-dir ./ci

      - name: Run dbt build
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
          SNOWFLAKE_ROLE: TRANSFORMER_DEV
          SNOWFLAKE_WAREHOUSE: TRANSFORMING_XS_DEV
          SNOWFLAKE_DATABASE: TRANSFORM_DEV
          DBT_SCHEMA_PREFIX: GH_CI_PR_${{ github.event.pull_request.number }}
        run: |
          uv run dbt build --profiles-dir ./ci --target ci
```

### Step 2: Create CI dbt Profile

Create `ci/profiles.yml` in your repository:

```yaml
default:
  outputs:
    ci:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      user: "{{ env_var('SNOWFLAKE_USER') }}"
      password: "{{ env_var('SNOWFLAKE_PASSWORD') }}"
      role: "{{ env_var('SNOWFLAKE_ROLE') }}"
      warehouse: "{{ env_var('SNOWFLAKE_WAREHOUSE') }}"
      database: "{{ env_var('SNOWFLAKE_DATABASE') }}"
      schema: "{{ env_var('DBT_SCHEMA_PREFIX') }}"
      threads: 4
  target: ci
```

**Important:** This file can be committed to git because it uses environment variables, not actual credentials.

---

## Exercise 3: Configure GitHub Secrets

### Step 1: Obtain Service Account Credentials

Contact your Snowflake administrator for a service account with:
- Username (e.g., `GH_ACTIONS_SVC`)
- Password
- Role: `TRANSFORMER_DEV`
- Access to `TRANSFORM_DEV` database

### Step 2: Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

| Secret Name | Example Value | Description |
|-------------|---------------|-------------|
| `SNOWFLAKE_ACCOUNT` | `orgname-accountname` | Your Snowflake account identifier |
| `SNOWFLAKE_USER` | `GH_ACTIONS_SVC` | Service account username |
| `SNOWFLAKE_PASSWORD` | `••••••••` | Service account password |

**Security note:** Secrets are encrypted and never displayed after creation.

### Step 3: Test Authentication

1. Push your changes
2. Create a PR
3. Check GitHub Actions logs for "Run dbt debug" step
4. Should see "Connection test: OK"

---

## Exercise 4: Debug a Failing CI Run

### Scenario: SQL Syntax Error

Let's intentionally create an error to practice debugging.

### Step 1: Introduce an Error

Edit one of your staging models to have a syntax error:

```sql
-- Intentional error: missing comma
select
    station_id
    station_name  -- Missing comma here!
from {{ source('water_quality', 'stations') }}
```

### Step 2: Commit and Push

```bash
git add models/staging/stg_water_quality__stations.sql
git commit -m "Test: introduce syntax error"
git push
```

### Step 3: Observe CI Failure

1. Go to GitHub Actions tab
2. Click on the failing workflow run
3. Expand "Run dbt build" step
4. Read the error message

**Example error:**
```
Compilation Error in model stg_water_quality__stations
  syntax error at or near "station_name"
```

### Step 4: Fix the Error

Add the missing comma:

```sql
select
    station_id,  -- Fixed!
    station_name
from {{ source('water_quality', 'stations') }}
```

### Step 5: Verify Fix

```bash
git add models/staging/stg_water_quality__stations.sql
git commit -m "Fix syntax error"
git push
```

CI should now pass ✓

---

## Common CI Debugging Scenarios

### Scenario 1: "Database does not exist"

**Error:**
```
Database 'TRANSFORM_DEV' does not exist
```

**Cause:** Service account doesn't have access to the database

**Solution:**
1. Verify database name in GitHub secrets
2. Check service account role has USAGE on database:
   ```sql
   GRANT USAGE ON DATABASE TRANSFORM_DEV TO ROLE TRANSFORMER_DEV;
   ```

---

### Scenario 2: "Authentication failed"

**Error:**
```
250001: Could not connect to Snowflake backend
```

**Cause:** Incorrect credentials or account identifier

**Solution:**
1. Verify `SNOWFLAKE_ACCOUNT` format: `orgname-accountname` (not URL)
2. Check username/password are correct
3. Ensure service account is not locked or expired

---

### Scenario 3: "Secret not found"

**Error:**
```
Error: Input required and not supplied: SNOWFLAKE_PASSWORD
```

**Cause:** Secret not defined or typo in secret name

**Solution:**
1. Check spelling matches exactly in workflow and GitHub settings
2. Verify secret is at repository level (not environment level)
3. Re-create the secret if needed

---

### Scenario 4: "Schema already exists"

**Error:**
```
Schema 'GH_CI_PR_123' already exists
```

**Cause:** Previous CI run didn't clean up

**Solution:**
Add cleanup step to workflow (after dbt build):

```yaml
- name: Cleanup CI schema
  if: always()
  env:
    SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
    SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_USER }}
    SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PASSWORD }}
  run: |
    # Drop CI schema after run
    # (Implementation depends on your needs)
```

---

## Advanced: Production Deployment

### Create Production Workflow

Create `.github/workflows/dbt-prod.yml`:

```yaml
name: dbt Production

on:
  push:
    branches: [main]

jobs:
  dbt-prod:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v5
        with:
          enable-cache: true

      - name: Set up Python
        run: uv python install

      - name: Install dbt
        run: uv sync

      - name: Run dbt build (production)
        env:
          SNOWFLAKE_ACCOUNT: ${{ secrets.SNOWFLAKE_ACCOUNT }}
          SNOWFLAKE_USER: ${{ secrets.SNOWFLAKE_PROD_USER }}
          SNOWFLAKE_PASSWORD: ${{ secrets.SNOWFLAKE_PROD_PASSWORD }}
          SNOWFLAKE_ROLE: TRANSFORMER_PRD
          SNOWFLAKE_WAREHOUSE: TRANSFORMING_XS_PRD
          SNOWFLAKE_DATABASE: TRANSFORM_PRD
        run: |
          uv run dbt build --profiles-dir ./ci --target prod
```

**Key differences from CI:**
- Triggers on push to `main` (not PRs)
- Uses production credentials
- Uses `TRANSFORMER_PRD` role
- Builds in `TRANSFORM_PRD` database

---

## Verification Checklist

After completing this workshop, verify:

- [ ] Pre-commit workflow runs on every PR
- [ ] dbt build workflow runs on every PR
- [ ] CI uses service account (not personal credentials)
- [ ] CI builds in PR-specific schema (`GH_CI_PR_*`)
- [ ] Failed CI prevents PR merge
- [ ] Can debug CI failures using GitHub Actions logs
- [ ] Production workflow deploys on merge to main
- [ ] GitHub secrets are properly configured

---

## Next Steps

- **[Local to Production](../integration/local-to-production.md)** - See the complete flow from local dev to production
- **[End-to-End Workflow](../integration/end-to-end-workflow.md)** - See how CI/CD fits in the full pipeline
- **[Troubleshooting Guide](../Knowledge check/troubleshooting.md)** - More debugging scenarios

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [dbt CI/CD Best Practices](https://docs.getdbt.com/docs/deploy/continuous-integration)
- [Snowflake Service Accounts](https://docs.snowflake.com/en/user-guide/admin-user-management)
