# Custom Nexus image (with GCS blob store plugin)

| Item          | Value                                         |
|---------------|-----------------------------------------------|
| Base image    | `sonatype/nexus3:3.61.0`                       |
| Plugin        | `nexus-blobstore-google-cloud` `0.61.0`        |
| Install dir   | `/opt/sonatype/nexus/deploy/`                  |

`0.61.0` is the final open-source release of the community GCS plugin (archived
Nov 2024), so `3.61.0` is the newest Nexus version with a version-matched free
plugin.

## Test locally (optional, verifies the plugin loads)

```bash
docker build -t nexus-gcs:local .
docker run --rm -p 8081:8081 nexus-gcs:local
# then open http://localhost:8081
# Admin > Blob Stores > Create: type "Google Cloud Storage" should be available
```

## Build & push to Artifact Registry

```bash
export PROJECT_ID=your-gcp-project
export REGION=us-central1
./build.sh
```

Override any of `PROJECT_ID`, `REGION`, `REPO`, `IMAGE`, `TAG` via env vars.
The script creates the Artifact Registry repo if needed, builds for
`linux/amd64` (required for GKE nodes even when building on Apple silicon),
and pushes the image.
