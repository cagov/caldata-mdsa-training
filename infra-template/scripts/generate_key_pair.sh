#!/usr/bin/env bash
#
# Generate an encrypted RSA key pair for the dbt service user and print the
# single-line public key to paste into terraform.tfvars.
#
# Usage:
#   bash scripts/generate_key_pair.sh <key-name> [passphrase]
#
# Example:
#   bash scripts/generate_key_pair.sh dbt_svc_dev "$(openssl rand -base64 24)"
#
# Outputs (written to the current directory):
#   <key-name>.p8      encrypted PRIVATE key  -> keep secret, add to GitHub secrets
#   <key-name>.pub     PUBLIC key             -> add to terraform.tfvars
#
set -euo pipefail

KEY_NAME="${1:-}"
PASSPHRASE="${2:-}"

if [[ -z "${KEY_NAME}" ]]; then
  echo "Usage: bash scripts/generate_key_pair.sh <key-name> [passphrase]" >&2
  exit 1
fi

if [[ -z "${PASSPHRASE}" ]]; then
  echo "No passphrase supplied; generating a random one." >&2
  PASSPHRASE="$(openssl rand -base64 24)"
  echo "Generated passphrase (store this in your secret manager):" >&2
  echo "  ${PASSPHRASE}" >&2
fi

# Encrypted PKCS#8 private key.
openssl genrsa 2048 |
  openssl pkcs8 -topk8 -v2 aes-256-cbc -inform PEM -out "${KEY_NAME}.p8" \
    -passout "pass:${PASSPHRASE}"

# Public key derived from the private key.
openssl rsa -in "${KEY_NAME}.p8" -passin "pass:${PASSPHRASE}" \
  -pubout -out "${KEY_NAME}.pub"

echo ""
echo "Wrote ${KEY_NAME}.p8 (private) and ${KEY_NAME}.pub (public)."
echo ""
echo "Single-line public key for terraform.tfvars (dbt_service_account_public_key):"
echo "----------------------------------------------------------------------------"
grep -v -e 'PUBLIC KEY' "${KEY_NAME}.pub" | tr -d '\n'
echo ""
echo "----------------------------------------------------------------------------"
echo ""
echo "For the GitHub secret SNOWFLAKE_PRIVATE_KEY, paste the full contents of ${KEY_NAME}.p8."
