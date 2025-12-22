#!/usr/bin/env bash
set -euo pipefail

OWNER="Azure"
REPO="terraform-state-importer"
FORMULA_PATH="Formula/terraform-state-importer.rb"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to parse the GitHub API response" >&2
  exit 1
fi

auth_header=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
  auth_header=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

latest_tag=$(curl -fsSL "${auth_header[@]}" "https://api.github.com/repos/${OWNER}/${REPO}/releases/latest" | jq -r '.tag_name')
if [ -z "$latest_tag" ] || [ "$latest_tag" = "null" ]; then
  echo "Unable to determine latest release tag" >&2
  exit 1
fi

version="${latest_tag#v}"
current_version=$(python3 - "$FORMULA_PATH" <<'PY'
import re
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as handle:
    content = handle.read()

match = re.search(r'^  version "([^"]+)"', content, re.M)
print(match.group(1) if match else "")
PY
)
if [ -z "$current_version" ]; then
  echo "Unable to read current version from ${FORMULA_PATH}" >&2
  exit 1
fi

if [ "$version" = "$current_version" ]; then
  echo "Formula already up to date at ${version}"
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

sha256_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
    return
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
    return
  fi
  echo "Missing sha256 tool (sha256sum or shasum)" >&2
  exit 1
}

for platform in darwin_amd64 darwin_arm64 linux_amd64 linux_arm64; do
  filename="terraform-state-importer_${version}_${platform}.tar.gz"
  url="https://github.com/${OWNER}/${REPO}/releases/download/${latest_tag}/${filename}"
  curl -fsSL "${auth_header[@]}" "$url" -o "$tmpdir/$filename"
  sha=$(sha256_file "$tmpdir/$filename")
  case "$platform" in
    darwin_amd64) SHA_DARWIN_AMD64="$sha" ;;
    darwin_arm64) SHA_DARWIN_ARM64="$sha" ;;
    linux_amd64) SHA_LINUX_AMD64="$sha" ;;
    linux_arm64) SHA_LINUX_ARM64="$sha" ;;
  esac
done

export FORMULA_PATH
export NEW_VERSION="$version"
export SHA_DARWIN_AMD64
export SHA_DARWIN_ARM64
export SHA_LINUX_AMD64
export SHA_LINUX_ARM64

python3 - <<'PY'
import os
import re
import sys

path = os.environ["FORMULA_PATH"]
version = os.environ["NEW_VERSION"]
sha_map = {
    "darwin_amd64": os.environ["SHA_DARWIN_AMD64"],
    "darwin_arm64": os.environ["SHA_DARWIN_ARM64"],
    "linux_amd64": os.environ["SHA_LINUX_AMD64"],
    "linux_arm64": os.environ["SHA_LINUX_ARM64"],
}

with open(path, "r", encoding="utf-8") as handle:
    text = handle.read()

text, count = re.subn(r'^  version ".*"$', f'  version "{version}"', text, flags=re.M)
if count != 1:
    sys.exit("Failed to update version in formula")

for platform, sha in sha_map.items():
    pattern = rf'(url ".*_{platform}\.tar\.gz"\n\s+sha256 ")[0-9a-f]+(")'
    text, count = re.subn(pattern, rf'\1{sha}\2', text)
    if count != 1:
        sys.exit(f"Failed to update sha for {platform}")

with open(path, "w", encoding="utf-8") as handle:
    handle.write(text)
PY

if [ -n "${GITHUB_ENV:-}" ]; then
  echo "NEW_VERSION=${version}" >> "$GITHUB_ENV"
fi

echo "Updated formula to ${version}"
