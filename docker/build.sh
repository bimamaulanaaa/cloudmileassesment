#!/usr/bin/env bash
#
# Build the custom Nexus image and push it to Google Artifact Registry.
#
# Prereqs: gcloud + docker (with buildx) installed and authenticated
#   gcloud auth login
#   gcloud auth application-default login
#
# Usage:
#   PROJECT_ID=my-project REGION=us-central1 ./build.sh
#
set -euo pipefail

# --- Config (override via env vars) ------------------------------------------
PROJECT_ID="${PROJECT_ID:?set PROJECT_ID, e.g. export PROJECT_ID=my-gcp-project}"
REGION="${REGION:-us-central1}"
REPO="${REPO:-nexus}"                 # Artifact Registry repository name
IMAGE="${IMAGE:-nexus-gcs}"           # image name
TAG="${TAG:-3.61.0}"                  # image tag (mirrors the Nexus version)

REGISTRY="${REGION}-docker.pkg.dev"
IMAGE_URI="${REGISTRY}/${PROJECT_ID}/${REPO}/${IMAGE}:${TAG}"

echo ">> Target image: ${IMAGE_URI}"

# --- 1. Ensure the Artifact Registry repo exists -----------------------------
if ! gcloud artifacts repositories describe "${REPO}" \
      --location="${REGION}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
  echo ">> Creating Artifact Registry repo '${REPO}' in ${REGION}..."
  gcloud artifacts repositories create "${REPO}" \
    --repository-format=docker \
    --location="${REGION}" \
    --project="${PROJECT_ID}" \
    --description="Custom Nexus images"
else
  echo ">> Artifact Registry repo '${REPO}' already exists."
fi

# --- 2. Configure docker auth for this registry ------------------------------
echo ">> Configuring docker auth for ${REGISTRY}..."
gcloud auth configure-docker "${REGISTRY}" --quiet

# --- 3. Build (linux/amd64) and push -----------------------------------------
# GKE nodes are amd64; force the platform so an Apple-silicon/ARM host still
# produces an image the cluster can run.
echo ">> Building and pushing (linux/amd64)..."
docker buildx build \
  --platform linux/amd64 \
  --tag "${IMAGE_URI}" \
  --push \
  "$(dirname "$0")"

echo ">> Done."
echo ">> Pushed: ${IMAGE_URI}"
