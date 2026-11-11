#!/usr/bin/env bash
# Pack each packages/* directory as an OCI artifact (ORAS → registry).
# DRY_RUN=1 validates package.json and prints push commands without pushing.
set -euo pipefail

# Prefer PACK_ROOT, then cwd (Docker/CI: -w /work), then sibling of pack/ when run as pack/pack.sh.
if [[ -n "${PACK_ROOT:-}" ]]; then
  ROOT="$(cd "${PACK_ROOT}" && pwd)"
elif [[ -d "${PWD}/packages" ]]; then
  ROOT="${PWD}"
elif [[ -d "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/packages" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  echo "pack: set PACK_ROOT or run from the silentorb-agents repo root" >&2
  exit 1
fi
PACKAGES_DIR="${ROOT}/packages"
REGISTRY="${REGISTRY:-ghcr.io/silentorb}"
ARTIFACT_TYPE="${ARTIFACT_TYPE:-application/vnd.silentorb.agents.package.v1+json}"
CONFIG_MEDIA_TYPE="${CONFIG_MEDIA_TYPE:-application/vnd.silentorb.agents.package.config.v1+json}"
DRY_RUN="${DRY_RUN:-0}"
SOURCE_URL="${SOURCE_URL:-https://github.com/silentorb/silentorb-agents}"

if ! command -v jq >/dev/null 2>&1; then
  echo "pack: jq is required" >&2
  exit 1
fi

if [[ "${DRY_RUN}" != "1" ]] && ! command -v oras >/dev/null 2>&1; then
  echo "pack: oras is required unless DRY_RUN=1" >&2
  exit 1
fi

shopt -s nullglob
package_dirs=("${PACKAGES_DIR}"/*/)
if [[ ${#package_dirs[@]} -eq 0 ]]; then
  echo "pack: no packages under ${PACKAGES_DIR}" >&2
  exit 1
fi

for dir in "${package_dirs[@]}"; do
  pkg_json="${dir}package.json"
  if [[ ! -f "${pkg_json}" ]]; then
    echo "pack: missing package.json in ${dir}" >&2
    exit 1
  fi

  name="$(jq -r '.name // empty' "${pkg_json}")"
  version="$(jq -r '.version // empty' "${pkg_json}")"
  if [[ -z "${name}" || -z "${version}" ]]; then
    echo "pack: ${pkg_json} must have name and version" >&2
    exit 1
  fi
  if [[ ! -f "${dir}AGENTS.md" ]]; then
    echo "pack: missing AGENTS.md in ${dir}" >&2
    exit 1
  fi

  ref="${REGISTRY}/${name}:${version}"
  echo "pack: ${name}@${version} → ${ref}"

  if [[ "${DRY_RUN}" == "1" ]]; then
    echo "  (dry-run) would oras push ${ref}"
    continue
  fi

  (
    cd "${dir}"
    # Push package directory contents; package.json as config blob.
    oras push "${ref}" \
      --artifact-type "${ARTIFACT_TYPE}" \
      --config "package.json:${CONFIG_MEDIA_TYPE}" \
      --annotation "org.opencontainers.image.source=${SOURCE_URL}" \
      --annotation "org.opencontainers.image.title=${name}" \
      --annotation "org.opencontainers.image.version=${version}" \
      .
  )
done

echo "pack: done"
