# Terraform — GCP infrastructure

Provisions everything the Nexus deployment needs:

| Resource                  | Notes                                                        |
|---------------------------|-------------------------------------------------------------|
| Cloud Storage bucket      | Blob store target, uniform access, `force_destroy = true`.  |
| GKE cluster (zonal)       | Single zone so the node pool is truly 1 node.               |
| Node pool                 | 1x `n1-standard-1`, **preemptible**, Workload Identity on.  |
| Artifact Registry repo    | Docker repo for the custom Nexus image.                     |
| Service account + IAM     | GSA with `storage.objectAdmin` on the bucket; bound to the  |
|                           | KSA `nexus/nexus` via Workload Identity.                    |

## Usage

```bash
cd terraform
cp example.tfvars terraform.tfvars   # then edit values (this file is gitignored)
terraform init
terraform plan  -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

`bucket_name` must be globally unique. After apply, connect kubectl with the
printed `get_credentials_command` output.

## Outputs

- `bucket_name`, `gsa_email`, `artifact_registry_repo`
- `get_credentials_command` — ready-to-run `gcloud ... get-credentials`

The `gsa_email` and `k8s_namespace/k8s_service_account` values feed directly
into the Helm chart in `../k8s` (Workload Identity annotation).
