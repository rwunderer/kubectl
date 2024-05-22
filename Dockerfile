#-------------------
# Download kubectl
#-------------------
FROM alpine:3.20.0@sha256:77726ef6b57ddf65bb551896826ec38bc3e53f75cdde31354fbffb4f25238ebd as builder

# renovate: datasource=github-releases depName=kubectl lookupName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.30.1
# renovate: datasource=github-releases depName=jq lookupName=jqlang/jq
ARG JQ_VERSION=1.7
ARG TARGETARCH
ARG TARGETOS
ARG TARGETVARIANT

# FAKE to trick renovate in to updating...
# renovate: datasource=github-releases depName=upcloud-cli lookupName=UpCloudLtd/upcloud-cli
ARG UPCTL_VERSION=3.8.0

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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:e9ac71e2b8e279a8372741b7a0293afda17650d926900233ec3a7b2b7c22a246 as kubectl-minimal

COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:8c26ef9be997951f136778615affb58c4b8fda06c06f3abc17e68322228d884e as kubectl-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]
