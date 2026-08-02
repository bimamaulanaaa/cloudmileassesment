# Nexus on GKE with Cloud Storage Blob Store

SRE exercise: run [Sonatype Nexus 3](https://hub.docker.com/r/sonatype/nexus3/) on
Google Kubernetes Engine (GKE), storing uploaded artifacts in a Google Cloud
Storage (GCS) bucket via the
[Google Cloud Blob Store plugin](https://help.sonatype.com/en/google-cloud-blob-store.html).

## Architecture

```
Client ──> GKE LoadBalancer ──> Nexus Pod (custom image, 1x n1-standard-1 preemptible)
                                    │
                                    ├── /nexus-data ──> PersistentVolume (dynamically provisioned)
                                    └── GCS Blob Store ──> Cloud Storage bucket
                                           (auth via Workload Identity)
```

## Repository layout

| Path         | Purpose                                                                    |
|--------------|----------------------------------------------------------------------------|
| `docker/`    | `Dockerfile` (Nexus 3.61.0 + GCS plugin 0.61.0) and `build.sh` (build & push). |
| `k8s/nexus/` | Helm chart: Service + PersistentVolumeClaim + Deployment + Workload Identity SA. |
| `terraform/` | GCS bucket + GKE cluster (1x `n1-standard-1`, preemptible) + Artifact Registry + IAM. |
| `captures/`  | Screenshots of the deployment / stored artifact.                            |

## Deliverables (assessment subtasks)

| # | Subtask                     | Deliverable                                   | Status |
|---|-----------------------------|-----------------------------------------------|--------|
| 1 | Custom container            | `docker/Dockerfile`                           | Done — builds locally, plugin `.kar` downloads successfully. |
| 2 | Kubernetes configs (Helm)   | `k8s/nexus/`                                  | Done — `helm lint` + `helm template` pass. |
| 3 | GCP resources (Terraform)   | `terraform/`                                  | Done — `terraform validate` passes; `plan` produces 10 resources. |
| 4 | Deploy                      | `captures/`                                   | Blocked — see note below. |
| 5 | Continuous integration      | This README, section [5](#5-continuous-integration-cicd) | Done. |

### Version pairing (why 3.61.0 / 0.61.0)

The community `nexus-blobstore-google-cloud` plugin uses a matched scheme
(plugin `0.X` targets Nexus `3.X`) and was archived in Nov 2024. `0.61.0` is the
final open-source release, so `3.61.0` is the newest Nexus version with a
version-matched, freely available plugin.

### Note on subtask 4 (deploy)

The live deployment to GCP could not be completed because enabling **billing** on
the target project was blocked on Google's side (`OR_BACR2_44` / a required
one-time regional prepayment). GKE and GCS both require an active billing
account, so no cloud resources could be created. Everything needed to deploy is
in this repo and is reproducible on any project with billing enabled — see
[How to deploy](#how-to-deploy).

## How to deploy

```bash
# 1. Provision infrastructure
cd terraform
cp example.tfvars terraform.tfvars   # set project_id and a globally-unique bucket_name
terraform init
terraform apply -var-file=terraform.tfvars

# 2. Build and push the custom image to Artifact Registry
cd ../docker
PROJECT_ID=<project> REGION=us-central1 ./build.sh

# 3. Connect kubectl (use the get_credentials_command from terraform output)
gcloud container clusters get-credentials nexus-cluster --zone us-central1-a --project <project>

# 4. Deploy with Helm
kubectl create namespace nexus
helm install nexus ./k8s/nexus -n nexus

# 5. Get the external IP and initial admin password
kubectl get svc nexus -n nexus -w
kubectl exec -n nexus deploy/nexus -- cat /nexus-data/admin.password
```

Then in the Nexus UI: create a **Google Cloud Storage** blob store pointing at the
bucket, create a repository backed by it, upload an artifact, and confirm the
object appears in the bucket.

## 5. Continuous Integration (CI/CD)

**Goal:** when the Dockerfile, Helm chart, or Terraform change on Git (e.g. a new
Nexus version), the change should be built and deployed to a **test environment**
automatically.

**Approach — a Git-triggered pipeline (GitHub Actions, since the repo is on GitHub):**

1. **Trigger.** The workflow runs on push/merge to a `test` branch (or on merge to
   `main` for the test environment). Pull requests run validation only.

2. **Validate.** Cheap gates first: `hadolint` on the Dockerfile, `helm lint` on
   the chart, `terraform fmt -check` + `terraform validate`.

3. **Build & push.** Build the image with the pinned Nexus version, tag it with the
   **commit SHA** (immutable, traceable) plus a moving `test` tag, and push to
   **Artifact Registry**. Authenticate from the runner keylessly using **Workload
   Identity Federation** for GitHub Actions — no service-account JSON keys stored.

4. **Deploy to test.** Run `helm upgrade --install nexus ./k8s/nexus -n nexus-test`
   against the test cluster/namespace, overriding `image.tag` with the commit SHA.
   Helm makes the rollout declarative and idempotent.

5. **Verify.** A smoke step waits for the rollout (`kubectl rollout status`) and
   checks Nexus responds, failing the pipeline if the new version is unhealthy.

6. **Infra changes.** Terraform changes run `terraform plan` on the PR (posted for
   review) and `terraform apply` only after merge, so infra and app deploy from the
   same Git event.

**Promotion.** The test environment deploys automatically on every change; promotion
to production is a separate, gated step (manual approval or a release tag) that
reuses the same SHA-tagged image — build once, promote the same artifact.

**Alternative (GitOps).** Instead of pushing from CI, a tool like **Argo CD** or
**Flux** watches the repo and continuously reconciles the cluster to match Git.
CI then only builds/pushes the image and bumps the tag in the chart; the GitOps
controller handles the deploy. This gives auditability and automatic drift
correction.
