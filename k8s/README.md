# Kubernetes — Helm chart

Deploys Nexus as three units required by the exercise:

| Unit               | Template                        |
|--------------------|---------------------------------|
| Service            | `templates/service.yaml` (LoadBalancer) |
| Persistence volume | `templates/pvc.yaml` (PVC → GKE dynamically provisions the PersistentVolume) |
| Deployment         | `templates/deployment.yaml`     |

Plus a `ServiceAccount` annotated for **Workload Identity**, bound to the GCP
service account created by Terraform.

## Before installing

Set your project in `values.yaml` (or override with `--set`):

- `image.repository` → `REGION-docker.pkg.dev/PROJECT_ID/nexus/nexus-gcs`
- `serviceAccount.gcpServiceAccount` → `nexus-gcs@PROJECT_ID.iam.gserviceaccount.com`

These must match the Terraform outputs (`artifact_registry_repo`, `gsa_email`).

## Install

```bash
gcloud container clusters get-credentials nexus-cluster --zone us-central1-a --project PROJECT_ID
kubectl create namespace nexus
helm install nexus ./nexus -n nexus \
  --set image.repository=REGION-docker.pkg.dev/PROJECT_ID/nexus/nexus-gcs \
  --set serviceAccount.gcpServiceAccount=nexus-gcs@PROJECT_ID.iam.gserviceaccount.com
```

The namespace/service-account (`nexus`/`nexus`) must match the Workload Identity
binding in Terraform (`k8s_namespace` / `k8s_service_account`).

## Notes

- **JVM heap** is capped via `INSTALL4J_ADD_VM_PARAMS` so Nexus fits on a single
  `n1-standard-1` (3.75 GB) node.
- **`fsGroup: 200`** makes the mounted volume writable by the `nexus` user.
- **`strategy: Recreate`** because the RWO volume can't attach to two pods at once.
- Get the external IP: `kubectl get svc nexus -n nexus -w`
- Initial admin password: `kubectl exec -n nexus deploy/nexus -- cat /nexus-data/admin.password`
