#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:?set PROJECT_ID, e.g. export PROJECT_ID=my-gcp-project}"
REGION="${REGION:-us-central1}"
REPO="${REPO:-nexus}"
IMAGE="${IMAGE:-nexus-gcs}"
TAG="${TAG:-3.61.0}"

REGISTRY="${REGION}-docker.pkg.dev"
IMAGE_URI="${REGISTRY}/${PROJECT_ID}/${REPO}/${IMAGE}:${TAG}"

echo ">> Target image: ${IMAGE_URI}"

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

echo ">> Configuring docker auth for ${REGISTRY}..."
gcloud auth configure-docker "${REGISTRY}" --quiet

echo ">> Building and pushing (linux/amd64)..."
docker buildx build \
  --platform linux/amd64 \
  --tag "${IMAGE_URI}" \
  --push \
  "$(dirname "$0")"

echo ">> Done."
echo ">> Pushed: ${IMAGE_URI}"
