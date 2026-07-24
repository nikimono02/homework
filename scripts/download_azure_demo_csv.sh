#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TERRAFORM_DIR="$REPO_ROOT/terraform"
OUTPUT_DIR="$TERRAFORM_DIR/output"

mkdir -p "$OUTPUT_DIR"

storage_account_name="$(terraform -chdir="$TERRAFORM_DIR" output -raw storage_account_name)"
container_name="$(terraform -chdir="$TERRAFORM_DIR" output -raw storage_container_name)"
blob_name="$(terraform -chdir="$TERRAFORM_DIR" output -raw csv_blob_name)"
target_file="$OUTPUT_DIR/$(basename "$blob_name")"

az storage blob download \
  --auth-mode login \
  --account-name "$storage_account_name" \
  --container-name "$container_name" \
  --name "$blob_name" \
  --file "$target_file" \
  --overwrite

echo "Downloaded CSV to $target_file"
