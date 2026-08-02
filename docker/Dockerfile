# Custom Sonatype Nexus 3 image with the Google Cloud Storage blob store plugin
# baked in. See https://help.sonatype.com/en/google-cloud-blob-store.html
#
# Version pairing is strict: plugin 0.X targets Nexus 3.X.
# 0.61.0 is the final open-source community release, so 3.61.0 is the newest
# Nexus version with a version-matched, freely available plugin.

FROM sonatype/nexus3:3.61.0

ARG PLUGIN_VERSION=0.61.0
ARG PLUGIN_KAR=nexus-blobstore-google-cloud-${PLUGIN_VERSION}-bundle.kar
ARG PLUGIN_URL=https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/${PLUGIN_VERSION}/${PLUGIN_KAR}

# The base image runs as the unprivileged "nexus" user (uid 200); switch to root
# only to drop the .kar into the auto-deploy directory, then switch back.
USER root

RUN curl -fSL "${PLUGIN_URL}" -o "/opt/sonatype/nexus/deploy/${PLUGIN_KAR}" \
    && chown nexus:nexus "/opt/sonatype/nexus/deploy/${PLUGIN_KAR}"

USER nexus

# Nexus serves the UI/API on 8081 (already EXPOSEd by the base image, repeated
# here for clarity).
EXPOSE 8081
