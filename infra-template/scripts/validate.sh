#!/usr/bin/env bash
#
# Validate the self-service training environment.
#
# Runs a series of checks and prints a clear PASS/FAIL for each:
#   1. Terraform is formatted and valid.
#   2. Terraform state exists and reports the expected objects (if applied).
#   3. dbt project parses (offline, structural check).
#   4. dbt compile succeeds - needs credentials.
#   5. Snowflake connection + objects + grants work (dbt debug) - needs credentials.
#   6. dbt build succeeds end-to-end (seed + models + tests) - needs credentials.
#
# Steps 4, 5, and 6 are skipped (not failed) when Snowflake credentials are not
# set, so the script is useful both locally and in CI.
#
# Usage:
#   bash scripts/validate.sh
#
# Exit code is 0 only if every check that ran passed.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${REPO_ROOT}/terraform"
DBT_DIR="${REPO_ROOT}/transform"

# ---- output helpers ---------------------------------------------------------
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YELLOW=$'\033[0;33m'; BOLD=$'\033[1m'; NC=$'\033[0m'
else
  GREEN=""; RED=""; YELLOW=""; BOLD=""; NC=""
fi

FAILURES=0
pass() { echo "${GREEN}  PASS${NC}  $1"; }
fail() { echo "${RED}  FAIL${NC}  $1"; FAILURES=$((FAILURES + 1)); }
skip() { echo "${YELLOW}  SKIP${NC}  $1"; }
header() { echo ""; echo "${BOLD}==> $1${NC}"; }

# dbt is invoked through uv so no global install is required.
DBT=(uv run --with dbt-snowflake dbt)

# ---- 1. terraform fmt + validate -------------------------------------------
header "1. Terraform format and validation"
if ! command -v terraform >/dev/null 2>&1; then
  fail "terraform is not installed"
else
  if terraform -chdir="${TF_DIR}" fmt -check -recursive >/dev/null 2>&1; then
    pass "terraform fmt (no formatting changes needed)"
  else
    fail "terraform fmt found unformatted files (run: terraform -chdir=terraform fmt -recursive)"
  fi

  if [[ ! -d "${TF_DIR}/.terraform" ]]; then
    terraform -chdir="${TF_DIR}" init -backend=false -input=false >/dev/null 2>&1 || true
  fi
  if terraform -chdir="${TF_DIR}" validate >/dev/null 2>&1; then
    pass "terraform validate"
  else
    fail "terraform validate (run: terraform -chdir=terraform validate)"
  fi
fi

# ---- 2. terraform state / outputs ------------------------------------------
header "2. Terraform state and expected objects"
if terraform -chdir="${TF_DIR}" output -json >/tmp/tf_out.json 2>/dev/null && [[ -s /tmp/tf_out.json ]] && [[ "$(cat /tmp/tf_out.json)" != "{}" ]]; then
  DB=$(python3 -c "import json;print(json.load(open('/tmp/tf_out.json'))['database_name']['value'])" 2>/dev/null || echo "")
  WHS=$(python3 -c "import json;print(len(json.load(open('/tmp/tf_out.json'))['warehouse_names']['value']))" 2>/dev/null || echo "0")
  ROLES=$(python3 -c "import json;print(len(json.load(open('/tmp/tf_out.json'))['role_names']['value']))" 2>/dev/null || echo "0")
  [[ -n "${DB}" ]] && pass "database output present: ${DB}" || fail "database output missing"
  [[ "${WHS}" == "3" ]] && pass "3 warehouses in outputs" || fail "expected 3 warehouses, found ${WHS}"
  [[ "${ROLES}" == "3" ]] && pass "3 functional roles in outputs" || fail "expected 3 roles, found ${ROLES}"
else
  skip "no terraform outputs yet (run 'terraform apply' first)"
fi

# ---- 3. dbt parse (offline) ------------------------------------------------
header "3. dbt project structure (offline parse)"
export DBT_PROFILES_DIR="${DBT_DIR}"
if "${DBT[@]}" deps --project-dir "${DBT_DIR}" >/dev/null 2>&1; then
  pass "dbt deps"
else
  fail "dbt deps"
fi
if "${DBT[@]}" parse --project-dir "${DBT_DIR}" >/dev/null 2>&1; then
  pass "dbt parse (project compiles structurally)"
else
  fail "dbt parse"
fi

# ---- 4. dbt compile --------------------------------------------------------
# compile resolves refs/sources against the warehouse, so it needs credentials.
# Skip (do not fail) when they are absent, matching the offline contract.
header "4. dbt compile"
if [[ -z "${SNOWFLAKE_USER:-}" ]] || { [[ -z "${SNOWFLAKE_PRIVATE_KEY:-}" ]] && [[ -z "${SNOWFLAKE_PRIVATE_KEY_PATH:-}" ]]; }; then
  skip "SNOWFLAKE_USER / private key not set; skipping dbt compile"
else
  if "${DBT[@]}" compile --project-dir "${DBT_DIR}" >/dev/null 2>&1; then
    pass "dbt compile"
  else
    fail "dbt compile (see: dbt compile --project-dir transform)"
  fi
fi

# ---- 5 & 6. live Snowflake checks ------------------------------------------
header "5. Snowflake connection, objects, and grants"
if [[ -z "${SNOWFLAKE_USER:-}" ]] || { [[ -z "${SNOWFLAKE_PRIVATE_KEY:-}" ]] && [[ -z "${SNOWFLAKE_PRIVATE_KEY_PATH:-}" ]]; }; then
  skip "SNOWFLAKE_USER / private key not set; skipping live checks"
else
  if "${DBT[@]}" debug --project-dir "${DBT_DIR}" >/dev/null 2>&1; then
    pass "dbt debug (connection, database, schema, warehouse, role all reachable)"
  else
    fail "dbt debug (see: dbt debug --project-dir transform)"
  fi

  header "6. dbt build (seed + models + tests exercise read/write grants)"
  if "${DBT[@]}" build --project-dir "${DBT_DIR}" >/dev/null 2>&1; then
    pass "dbt build (grants function: create/insert/select all succeeded)"
  else
    fail "dbt build (see: dbt build --project-dir transform)"
  fi
fi

# ---- summary ---------------------------------------------------------------
echo ""
if [[ "${FAILURES}" -eq 0 ]]; then
  echo "${GREEN}${BOLD}All checks that ran passed.${NC}"
  exit 0
else
  echo "${RED}${BOLD}${FAILURES} check(s) failed. See messages above.${NC}"
  exit 1
fi
