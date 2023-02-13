
FROM registry.access.redhat.com/ubi8 AS ubi-micro-build
ARG KC_VERSION=20.0.3
ARG KEYCLOAK_DIST=https://github.com/keycloak/keycloak/releases/download/${KC_VERSION:-20.0.3}/keycloak-${KC_VERSION:-20.0.3}.tar.gz

RUN dnf install -y tar gzip

ADD $KEYCLOAK_DIST /tmp/keycloak/

# The next step makes it uniform for local development and upstream built.
# If it is a local tar archive then it is unpacked, if from remote is just downloaded.
RUN (cd /tmp/keycloak && \
    tar -xvf /tmp/keycloak/keycloak-*.tar.gz && \
    rm /tmp/keycloak/keycloak-*.tar.gz) || true

RUN mv /tmp/keycloak/keycloak-* /opt/keycloak && mkdir -p /opt/keycloak/data
RUN chmod -R g+rwX /opt/keycloak

# add psql repo
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm 

# get file from original repo and run
RUN curl -o /tmp/ubi8-null.sh https://raw.githubusercontent.com/keycloak/keycloak/main/quarkus/container/ubi8-null.sh && \
    chmod +x /tmp/ubi8-null.sh
RUN bash /tmp/ubi8-null.sh java-17-openjdk-headless glibc-langpack-en postgresql15 curl

FROM registry.access.redhat.com/ubi8-micro
ENV LANG en_US.UTF-8

COPY --from=ubi-micro-build /tmp/null/rootfs/ /
COPY --from=ubi-micro-build --chown=1000:0 /opt/keycloak /opt/keycloak

RUN echo "keycloak:x:0:root" >> /etc/group && \
    echo "keycloak:x:1000:0:keycloak user:/opt/keycloak:/sbin/nologin" >> /etc/passwd

USER 1000

EXPOSE 8080
EXPOSE 8443

HEALTHCHECK CMD ["curl", "-f", "http://localhost:8080"]
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]