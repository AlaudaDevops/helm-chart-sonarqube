#! /bin/sh

BIN_PATH=${1:-"./bin"}

export YQ_VERSION=4.25.2
export KUBECTL_VERSION=1.28.2
export HELM_VERSION=3.12.3
export DOCKER_VERSION=26.0.2

# install dependencies
mkdir -p ${BIN_PATH}
if [ "$(arch)" = "arm64" ] || [ "$(arch)" = "aarch64" ]; then
    export ARCH="arm64"
else
    export ARCH="amd64"
fi

mkdir -p tmp
# install docker-cli
# curl -fsSLO https://download.docker.com/linux/static/stable/$(arch)/docker-${DOCKER_VERSION}.tgz &&
#     tar xzvf docker-${DOCKER_VERSION}.tgz --strip 1 \
#         -C ${BIN_PATH} docker/docker
# install yq
curl -sfL https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_${ARCH} -o ${BIN_PATH}/yq
# install kubectl
curl -sfL https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}/kubectl
# install helm
curl -sfL https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz | tar xzf - -C tmp 2>&1 && mv tmp/linux-${ARCH}/helm ${BIN_PATH}/helm

chmod +x ${BIN_PATH}/*

# test dependencies
PATH=${BIN_PATH}:$PATH
yq --version
kubectl version --client
helm version
