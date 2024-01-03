#!/usr/bin/env sh
set -e

name=
namespace="$HELM_NAMESPACE"
hargs=
kargs=

while [ $# -gt 0 ]; do
  key="$1"

  case $key in
  --kube-context)
    kargs="$kubectl --context $2"
    hargs="$helm --kube-context $2"
    shift
    shift
    ;;
  --kube-context=*)
    kargs="$kubectl --context=${key##*=}"
    hargs="$helm --kube-context=${key##*=}"
    shift
    ;;
  --kubeconfig)
    kargs="$kubectl --kubeconfig $2"
    hargs="$helm --kubeconfig $2"
    shift
    shift
    ;;
  --kubeconfig=*)
    kargs="$kubectl --kubeconfig=${key##*=}"
    hargs="$helm --kubeconfig=${key##*=}"
    shift
    ;;
  -n | --namespace)
    kargs="$kubectl --namespace $2"
    hargs="$helm --namespace $2"
    shift
    shift
    ;;
  --namespace=*)
    kargs="$kubectl --namespace=${key##*=}"
    hargs="$helm --namespace=${key##*=}"
    shift
    ;;
  --force-conflicts)
    kargs="$kargs --force-conflicts"
    shift
    ;;
  --force-conflicts=*)
    kargs="$kargs --force-conflicts=${key##*=}"
    shift
    ;;

  --*)
    hargs="$hargs $1"
    shift
    ;;
  *)
    if [ -z "$name" ]; then
      name=$1
    fi
    hargs="$hargs $1"
    shift
    ;;
  esac
done

crds=$(mktemp)
helm template $hargs --include-crds | yq e "select(.kind|downcase == \"customresourcedefinition\")
| .metadata.annotations.\"meta.helm.sh/release-name\"=\"$name\"
| .metadata.annotations.\"meta.helm.sh/release-namespace\"=\"$namespace\"
| .metadata.labels.\"app.kubernetes.io/managed-by\"=\"Helm\"
" > "$crds"
if [ -s "$crds" ]; then
  kubectl apply --server-side $kargs -f "$crds"
fi
rm -f "$crds"
