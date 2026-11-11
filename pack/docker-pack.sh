#!/usr/bin/env bash
# Build the packer image and run one ephemeral pack smoke (docker run --rm).
# Default DRY_RUN=1 (no registry push). Needs a host-resolvable bind mount path.
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-silentorb-agents-pack:local}"
DRY_RUN="${DRY_RUN:-1}"
REGISTRY="${REGISTRY:-ghcr.io/silentorb}"
SOURCE_URL="${SOURCE_URL:-https://github.com/silentorb/silentorb-agents}"

if [[ -n "${PACK_ROOT:-}" ]]; then
  ROOT="$(cd "${PACK_ROOT}" && pwd)"
elif [[ -d "${PWD}/packages" && -f "${PWD}/pack/Dockerfile" ]]; then
  ROOT="${PWD}"
elif [[ -d "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/packages" ]]; then
  ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
else
  echo "docker-pack: set PACK_ROOT or run from the silentorb-agents repo root" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker-pack: docker is required" >&2
  exit 1
fi

# Bind mounts are resolved by the host Docker daemon. Inside a
# docker-outside-of-docker workbench, $PWD is a container path and will not
# mount correctly unless an explicit host path is provided.
if [[ -n "${HOST_REPO_PATH:-}" ]]; then
  MOUNT_SRC="${HOST_REPO_PATH}"
elif [[ -n "${SILENTORB_AGENTS_REPO:-}" ]]; then
  MOUNT_SRC="${SILENTORB_AGENTS_REPO}"
else
  MOUNT_SRC="${ROOT}"
fi

if [[ -f /.dockerenv ]] && [[ -z "${HOST_REPO_PATH:-}" && -z "${SILENTORB_AGENTS_REPO:-}" ]]; then
  echo "docker-pack: refuse to bind-mount a container path under docker-outside-of-docker." >&2
  echo "  Set HOST_REPO_PATH (or SILENTORB_AGENTS_REPO) to the host path of this repo," >&2
  echo "  or run from the host / CI where \$PWD is host-visible." >&2
  echo "  For a no-Docker dry-run: DRY_RUN=1 bash pack/pack.sh" >&2
  exit 1
fi

echo "docker-pack: building ${IMAGE_TAG}"
docker build -f "${ROOT}/pack/Dockerfile" -t "${IMAGE_TAG}" "${ROOT}"

echo "docker-pack: running pack (DRY_RUN=${DRY_RUN}) with ${MOUNT_SRC} → /work"
docker run --rm \
  -e "DRY_RUN=${DRY_RUN}" \
  -e "REGISTRY=${REGISTRY}" \
  -e "SOURCE_URL=${SOURCE_URL}" \
  -v "${MOUNT_SRC}:/work" \
  -w /work \
  "${IMAGE_TAG}"

echo "docker-pack: done"
