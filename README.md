# helm-ensurecrds

Helm plugin to install and upgrade CRDs from the chart

###### Motivation

This plugin is a dirty workaround for upstream issues:

- helm/helm#7735
- helm/helm#10585
- helm/helm#5871

###### Plugin installation

- Install `yq` and `kubectl` dependencies
- Install the plugin:
  ```shell
  helm plugin install https://github.com/kvaps/helm-ensurecrds
  ```

###### Example usage

Just use the same args for `helm install` or `helm upgrade` but for `helm ensurecrds`:

```shell
helm repo add jetstack https://charts.jetstack.io
helm ensurecrds cert-manager -n cert-manager jetstack/cert-manager --set=installCRDs=true
helm install cert-manager -n cert-manager jetstack/cert-manager --set=installCRDs=true
```

> **Warning:** This is alpha version, use it at your own risk!
