#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'EOF'
Usage:
  export-after-images.sh OUTPUT_DIR [MANIFEST_FILE]

Reads .images[].after.full from IMAGE_MIGRATION.yaml and exports those images
as docker save tar files into OUTPUT_DIR.

Environment:
  PULL_IMAGES=0       Do not run docker pull before docker save.
  EXPORT_GZIP=1       Write .tar.gz files instead of .tar files.
  SKIP_EXISTING=1     Skip an image when its output file already exists.
  DRY_RUN=1           Print export plan without pulling or saving images.
  DOCKER_PLATFORM=... Pass --platform to docker pull, for example linux/amd64.
  DOCKER_BIN=docker   Docker-compatible CLI to use.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 2
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
output_dir="$1"
manifest_file="${2:-$repo_root/IMAGE_MIGRATION.yaml}"
docker_bin="${DOCKER_BIN:-docker}"
pull_images="${PULL_IMAGES:-1}"
export_gzip="${EXPORT_GZIP:-0}"
skip_existing="${SKIP_EXISTING:-0}"
dry_run="${DRY_RUN:-0}"
docker_platform="${DOCKER_PLATFORM:-}"

if ! command -v yq >/dev/null 2>&1; then
  echo "ERROR: yq is required" >&2
  exit 2
fi

if ! command -v "$docker_bin" >/dev/null 2>&1; then
  echo "ERROR: $docker_bin is required" >&2
  exit 2
fi

if [[ ! -f "$manifest_file" ]]; then
  echo "ERROR: manifest file not found: $manifest_file" >&2
  exit 2
fi

mkdir -p "$output_dir"

image_list="$output_dir/after-images.txt"
tmp_image_list="$(mktemp)"
trap 'rm -f "$tmp_image_list"' EXIT

yq e -r '.images[].after.full' "$manifest_file" \
  | awk 'NF && $0 != "null"' \
  | sort -u >"$tmp_image_list"

total="$(wc -l <"$tmp_image_list" | tr -d '[:space:]')"
if [[ "$total" -eq 0 ]]; then
  echo "ERROR: no after images found in $manifest_file" >&2
  exit 1
fi

cp "$tmp_image_list" "$image_list"

failed=0
index=0
while IFS= read -r image; do
  index=$((index + 1))
  safe_name="$(printf '%s' "$image" | sed -E 's/[^A-Za-z0-9._-]+/_/g; s/^_+//; s/_+$//')"
  if [[ "$export_gzip" == "1" ]]; then
    output_file="$output_dir/${safe_name}.tar.gz"
  else
    output_file="$output_dir/${safe_name}.tar"
  fi

  if [[ "$skip_existing" == "1" && -f "$output_file" ]]; then
    echo "SKIP [$index/$total] $image -> $output_file"
    continue
  fi

  if [[ "$dry_run" == "1" ]]; then
    echo "PLAN [$index/$total] $image -> $output_file"
    continue
  fi

  echo "EXPORT [$index/$total] $image"

  if [[ "$pull_images" != "0" ]]; then
    pull_args=(pull)
    if [[ -n "$docker_platform" ]]; then
      pull_args+=(--platform "$docker_platform")
    fi
    pull_args+=("$image")

    if ! "$docker_bin" "${pull_args[@]}"; then
      echo "FAIL pull $image" >&2
      failed=$((failed + 1))
      continue
    fi
  fi

  tmp_output="${output_file}.tmp"
  rm -f "$tmp_output"

  if [[ "$export_gzip" == "1" ]]; then
    if "$docker_bin" save "$image" | gzip -c >"$tmp_output"; then
      mv "$tmp_output" "$output_file"
    else
      rm -f "$tmp_output"
      echo "FAIL save $image" >&2
      failed=$((failed + 1))
      continue
    fi
  else
    if "$docker_bin" save -o "$tmp_output" "$image"; then
      mv "$tmp_output" "$output_file"
    else
      rm -f "$tmp_output"
      echo "FAIL save $image" >&2
      failed=$((failed + 1))
      continue
    fi
  fi

  echo "OK   [$index/$total] $output_file"
done <"$tmp_image_list"

if [[ "$failed" -ne 0 ]]; then
  echo "FAILED: $failed/$total images failed" >&2
  exit 1
fi

if [[ "$dry_run" == "1" ]]; then
  echo "DRY RUN: planned $total image exports to $output_dir"
else
  echo "SUCCESS: exported $total images to $output_dir"
fi
echo "Image list: $image_list"
