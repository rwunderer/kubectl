#-------------------
# Download kubectl
#-------------------
FROM alpine:3.19.1@sha256:c5b1261d6d3e43071626931fc004f70149baeba2c8ec672bd4f27761f8e1ad6b as builder

# renovate: datasource=github-releases depName=kubectl lookupName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.29.3
# renovate: datasource=github-releases depName=jq lookupName=jqlang/jq
ARG JQ_VERSION=1.7
ARG TARGETARCH
ARG TARGETOS
ARG TARGETVARIANT

# FAKE to trick renovate in to updating...
# renovate: datasource=github-releases depName=upcloud-cli lookupName=UpCloudLtd/upcloud-cli
ARG UPCTL_VERSION=3.6.0

WORKDIR /tmp

RUN apk --no-cache add --upgrade \
    curl

RUN curl -SsL -o jq https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-${TARGETARCH} && \
    install jq /bin/jq && \
    rm jq

RUN curl -SsLL -o kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl && \
    install kubectl /bin/kubectl && \
    rm kubectl

#-------------------
# Minimal image
#-------------------
FROM gcr.io/distroless/static-debian12:nonroot@sha256:42c88655018248be5b8ed88261fca620f6d0dd55996fbb591de4969f250120e9 as kubectl-minimal

COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:08baf3b9b25ef61b205195747e8d8b746f10317cc37a0250f9ca66312be8bd1d as kubectl-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]
