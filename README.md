# Nexus on GKE with Cloud Storage Blob Store

SRE exercise: run [Sonatype Nexus 3](https://hub.docker.com/r/sonatype/nexus3/) on
Google Kubernetes Engine (GKE), storing uploaded artifacts in a Google Cloud
Storage (GCS) bucket via the
[Google Cloud Blob Store plugin](https://help.sonatype.com/en/google-cloud-blob-store.html).

## Repository layout

| Path         | Purpose                                                              |
|--------------|---------------------------------------------------------------------|
| `docker/`    | Custom Nexus image with the GCS blob store plugin baked in.         |
| `k8s/`       | Helm chart deploying Service + PersistentVolume(Claim) + Deployment. |
| `terraform/` | Infra-as-code: GCS bucket + GKE cluster (1x `n1-standard-1`, preemptible). |
| `captures/`  | Screenshots of the working deployment and the artifact stored in GCS. |

## Deliverables (assessment subtasks)

1. **Custom container** — `docker/Dockerfile`
2. **Kubernetes configs** — `k8s/` (Helm chart: Service, PV/PVC, Deployment)
3. **GCP resource creation** — `terraform/`
4. **Deploy** — see `captures/` for evidence
5. **Continuous integration (theory)** — see [CI/CD section](#5-continuous-integration-theory) below

## Architecture

```
Client ──> GKE LoadBalancer ──> Nexus Pod (custom image)
                                    │
                                    ├── /nexus-data  (PersistentVolume)
                                    └── GCS Blob Store ──> Cloud Storage bucket
                                           (Workload Identity auth)
```

## How to build & deploy

> Full step-by-step lives in each subfolder. High-level:

```bash
# 1. Provision infra
cd terraform && terraform init && terraform apply

# 2. Build & push the custom image (Artifact Registry)
cd ../docker && ./build.sh   # or manual docker build/push

# 3. Deploy to GKE
gcloud container clusters get-credentials <cluster> --region <region>
helm install nexus ../k8s/nexus
```

## 5. Continuous Integration (theory)

_See dedicated section — added in Phase 5._

---

_Work in progress — building phase by phase._
