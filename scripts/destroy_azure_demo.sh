#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/terraform"

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI is required. Install it, then run 'az login'."
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform is required."
  exit 1
fi

if [ -z "${TF_VAR_subscription_id:-}" ]; then
  if [ -z "${ARM_SUBSCRIPTION_ID:-}" ]; then
    ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
    export ARM_SUBSCRIPTION_ID
  fi

  export TF_VAR_subscription_id="$ARM_SUBSCRIPTION_ID"
fi

echo "This will destroy the Azure resources managed by terraform/."
read -r -p "Type 'destroy' to continue: " confirmation

if [ "$confirmation" != "destroy" ]; then
  echo "Destroy cancelled."
  exit 0
fi

terraform -chdir="$TERRAFORM_DIR" destroy
