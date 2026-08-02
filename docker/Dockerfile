FROM sonatype/nexus3:3.61.0

ARG PLUGIN_VERSION=0.61.0
ARG PLUGIN_KAR=nexus-blobstore-google-cloud-${PLUGIN_VERSION}-bundle.kar
ARG PLUGIN_URL=https://repo1.maven.org/maven2/org/sonatype/nexus/plugins/nexus-blobstore-google-cloud/${PLUGIN_VERSION}/${PLUGIN_KAR}

USER root

RUN curl -fSL "${PLUGIN_URL}" -o "/opt/sonatype/nexus/deploy/${PLUGIN_KAR}" \
    && chown nexus:nexus "/opt/sonatype/nexus/deploy/${PLUGIN_KAR}"

USER nexus

EXPOSE 8081
