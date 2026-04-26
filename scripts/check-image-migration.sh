#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
manifest_file="${1:-$repo_root/IMAGE_MIGRATION.yaml}"
expected_prefix="${EXPECTED_IMAGE_PREFIX:-registry.inner.silinex.work/silinex-maas}"
check_amd64="${CHECK_AMD64:-0}"

if ! command -v yq >/dev/null 2>&1; then
  echo "ERROR: yq is required" >&2
  exit 2
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is required" >&2
  exit 2
fi

if [[ ! -f "$manifest_file" ]]; then
  echo "ERROR: manifest file not found: $manifest_file" >&2
  exit 2
fi

canonical_registry="$(yq e -r '.canonicalRegistry // ""' "$manifest_file")"
if [[ "$canonical_registry" != "$expected_prefix" ]]; then
  echo "ERROR: canonicalRegistry is '$canonical_registry', expected '$expected_prefix'" >&2
  exit 1
fi

tmp_manifest="$(mktemp)"
tmp_error="$(mktemp)"
trap 'rm -f "$tmp_manifest" "$tmp_error"' EXIT

total=0
failed=0

while IFS= read -r image; do
  [[ -n "$image" && "$image" != "null" ]] || continue
  total=$((total + 1))

  if [[ "$image" != "$expected_prefix/"* ]]; then
    echo "FAIL prefix $image"
    failed=$((failed + 1))
    continue
  fi

  if ! docker manifest inspect "$image" >"$tmp_manifest" 2>"$tmp_error"; then
    echo "FAIL missing $image"
    sed 's/^/  /' "$tmp_error" >&2
    failed=$((failed + 1))
    continue
  fi

  if [[ "$check_amd64" == "1" ]]; then
    architecture="$(docker manifest inspect -v "$image" 2>"$tmp_error" | yq e -r '.Descriptor.platform.architecture // .manifests[0].Descriptor.platform.architecture // "unknown"' - 2>/dev/null || true)"
    if [[ "$architecture" != "amd64" ]]; then
      echo "FAIL arch=$architecture $image"
      failed=$((failed + 1))
      continue
    fi
  fi

  echo "OK $image"
done < <(yq e -r '.images[].after.full' "$manifest_file" | sort -u)

if [[ "$total" -eq 0 ]]; then
  echo "ERROR: no images found in $manifest_file" >&2
  exit 1
fi

if [[ "$failed" -ne 0 ]]; then
  echo "FAILED: $failed/$total images failed"
  exit 1
fi

echo "SUCCESS: $total images exist under $expected_prefix"
