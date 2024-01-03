#!/usr/bin/env sh
set -e

kubectl=kubectl
helm=helm
name=
namespace="$HELM_NAMESPACE"

while [ $# -gt 0 ]; do
  key="$1"

  case $key in
  --kube-context)
    kubectl="$kubectl --context $2"
    helm="$helm --kube-context $2"
    shift
    shift
    ;;
  --kube-context=*)
    kubectl="$kubectl --context=${key##*=}"
    helm="$helm --kube-context=${key##*=}"
    shift
    ;;
  --kubeconfig)
    kubectl="$kubectl --kubeconfig $2"
    helm="$helm --kubeconfig $2"
    shift
    shift
    ;;
  --kubeconfig=*)
    kubectl="$kubectl --kubeconfig=${key##*=}"
    helm="$helm --kubeconfig=${key##*=}"
    shift
    ;;
  -n | --namespace)
    kubectl="$kubectl --namespace $2"
    helm="$helm --namespace $2"
    shift
    shift
    ;;
  --namespace=*)
    kubectl="$kubectl --namespace=${key##*=}"
    helm="$helm --namespace=${key##*=}"
    shift
    ;;
  --*)
    args="$args $1"
    shift
    ;;
  *)
    if [ -z "$name" ]; then
      name=$1
    fi
    args="$args $1"
    shift
    ;;
  esac
done

crds=$(mktemp)
$helm template $args --include-crds | yq e "select(.kind|downcase == \"customresourcedefinition\")
| .metadata.annotations.\"meta.helm.sh/release-name\"=\"$name\"
| .metadata.annotations.\"meta.helm.sh/release-namespace\"=\"$namespace\"
| .metadata.labels.\"app.kubernetes.io/managed-by\"=\"Helm\"
" > "$crds"
if [ -s "$crds" ]; then
  $kubectl apply --server-side -f "$crds"
fi
rm -f "$crds"
