#-------------------
# Download kubectl
#-------------------
FROM alpine:3.20.3@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d as builder

# renovate: datasource=github-releases depName=kubectl lookupName=kubernetes/kubernetes
ARG KUBECTL_VERSION=v1.31.1
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
FROM gcr.io/distroless/static-debian12:nonroot@sha256:dcd3f1f09adef5689088c9c4d96a8d98c889d8281d3946145074f89eafe7e1af as kubectl-minimal

COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]

#-------------------
# Debug image
#-------------------
FROM gcr.io/distroless/base-debian12:debug-nonroot@sha256:a9c14330a664f1d1a549f9772c35eeac3f74828f6fd29530b8cc203103dd8085 as kubectl-debug

COPY --from=builder /bin/jq /bin/jq
COPY --from=builder /bin/kubectl /bin/kubectl

ENTRYPOINT ["/bin/kubectl"]
