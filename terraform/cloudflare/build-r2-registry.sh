#!/usr/bin/env bash
#
# Builds the r2-registry worker bundle from the sibling clone of
# https://github.com/cloudflare/serverless-registry so Terraform can deploy it.
#
# Usage: ./build-r2-registry.sh
#
# The sibling repo location defaults to ../../../serverless-registry relative to
# this script (i.e. a clone next to hetzner-k3s-cluster). Override with:
#
#   SERVERLESS_REGISTRY_DIR=/path/to/serverless-registry ./build-r2-registry.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SERVERLESS_REGISTRY_DIR:-${SCRIPT_DIR}/../../../serverless-registry}" && pwd)"
OUT_DIR="dist"
BUNDLE="${REPO_DIR}/${OUT_DIR}/index.js"

if [ ! -f "${REPO_DIR}/package.json" ] || [ ! -f "${REPO_DIR}/wrangler.toml" ]; then
  echo "error: ${REPO_DIR} does not look like the serverless-registry repo" >&2
  echo "       (expected package.json and wrangler.toml; set SERVERLESS_REGISTRY_DIR to override)" >&2
  exit 1
fi

cd "${REPO_DIR}"

if [ ! -d node_modules ] || [ pnpm-lock.yaml -nt node_modules ]; then
  echo "==> Installing dependencies"
  pnpm install
fi

echo "==> Bundling worker (wrangler deploy --dry-run)"
npx wrangler deploy --env production --dry-run --outdir "${OUT_DIR}"

if [ ! -f "${BUNDLE}" ]; then
  echo "error: expected bundle not found at ${BUNDLE}" >&2
  echo "       wrangler output layout may have changed; update this script and" >&2
  echo "       local.registry_worker_bundle / main_module in registry.tf accordingly" >&2
  exit 1
fi

echo "==> Bundle ready: ${BUNDLE}"
shasum -a 256 "${BUNDLE}"
