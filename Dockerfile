#-------------------
# Download kubectl
#-------------------
FROM alpine:3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a as builder

# renovate: datasource=github-releases depName=kubectl lookupName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.31.2
# renovate: datasource=github-releases depName=jq lookupName=jqlang/jq
ARG JQ_VERSION=1.7
ARG TARGETARCH
ARG TARGETOS
ARG TARGETVARIANT

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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:3a03fc0826340c7deb82d4755ca391bef5adcedb8892e58412e1a6008199fa91 as kubectl-minimal

COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:2f827a4140eff1ee61dfbab4c6bf8b998980c875b7a7902d3c1c3d915cb12ffa as kubectl-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]
