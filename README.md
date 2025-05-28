[![GitHub license](https://img.shields.io/github/license/rwunderer/kubectl.svg)](https://github.com/rwunderer/kubectl/blob/main/LICENSE)
<a href="https://renovatebot.com"><img alt="Renovate enabled" src="https://img.shields.io/badge/renovate-enabled-brightgreen.svg?style=flat-square"></a>

***As a contribution to [unplug Trump](https://www.kuketz-blog.de/unplugtrump-mach-dich-digital-unabhaengig-von-trump-und-big-tech/) this repository has moved to [codeberg](https://codeberg.org/capercode/kubectl).***

# kubectl
Minimal Docker image with [kubectl](https://github.com/kubernetes/kubectl)

## Image variants

This image is based on [distroless](https://github.com/GoogleContainerTools/distroless) and comes in two variants:

### Minimal image

The minimal image is based on `gcr.io/distroless/static-debian12:nonroot` and does not contain a shell. It can be directly used from the command line, eg:

```
$ docker run --rm -it ghcr.io/rwunderer/kubectl:v1.27.7-minimal version --short
Flag --short has been deprecated, and will be removed in the future. The --short output will become the default.
Client Version: v1.27.7
Kustomize Version: v5.0.1
The connection to the server localhost:8080 was refused - did you specify the right host or port?
```

### Debug image

The debug images is based on `gcr.io/distroless/base-debian12:debug-nonroot` and contains a busybox shell for use in ci images.
As kubectl's output is also available in json it also containts [jq](https://github.com/jqlang/jq).

E.g. for GitLab CI do:

```
list images:
  image:
    name: ghcr.io/rwunderer/kubectl:v1.27.7-debug
    entrypoint: [""]
  script:
    - kubectl get nodes -o json | jq
```

## Workflows

| Badge      | Description
|------------|---------
|[![Auto-Tag](https://github.com/rwunderer/kubectl/actions/workflows/renovate-create-tag.yml/badge.svg)](https://github.com/rwunderer/kubectl/actions/workflows/renovate-create-tag.yml) | Automatic Tagging of new kubectl releases
|[![Docker](https://github.com/rwunderer/kubectl/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/rwunderer/kubectl/actions/workflows/docker-publish.yml) | Docker image build
