# Moon

## Introduction

Values for setting up [Moon](https://aerokube.com/moon/latest/) in Kubernetes within Westpac.

## Getting Started

See:
1. https://confluence.westpac.co.nz/display/BUSINESS/Moon for the installation guide.
2. https://github.com/aerokube/charts for the helm chart
3. https://aerokube.com/images/latest/ for updates to the images

## References

https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/ingress.md  
https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/external_dns.md  
https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/cert-manager.md  

When new IPs arrive need a dedicated IP.

## Prerequisites

Please follow [the instructions](https://confluence.westpac.co.nz/display/BUSINESS/SOPS) to complete the following steps:

- Install GPG
- Install SOPS
- Install helm-secrets plugin

## Install Moon

Kubernets config should contain:

```yaml
- context:
    cluster: etdc-test
    namespace: itcrowd-moon
    user: <salary id>
  name: itcrowd-moon
current-context: itcrowd-moon
```

Helm / Kubernetes commands:

```bash

helm repo add aerokube https://charts.aerokube.com
helm repo update

# for Test
kubectl config current-context
kubectl config use-context etdc-test
helm secrets upgrade --install -n itcrowd-moon moon aerokube/moon -f values.yaml -f values.test.yaml -f secrets.yaml

# for Prod
kubectl config current-context
kubectl config use-context etdc-prod
helm secrets upgrade --install -n itcrowd-moon moon aerokube/moon -f values.yaml -f values.prod.yaml -f secrets.yaml

kubectl -n itcrowd-moon get pods
kubectl -n itcrowd-moon get deployment.apps/moon -o yaml
```

## Notes

- If you've checked out the chart to make any changes this can be run using:
> `helm upgrade --install -n itcrowd-moon moon ./charts/moon -f values.yaml`

- To check the app and chart versions:
```bash
helm show chart aerokube/moon
helm search repo aerokube --versions
```
- Get the current chart:
```bash
helm -n itcrowd-moon list
helm -n itcrowd-moon get values moon
helm -n itcrowd-moon get manifest moon
```

## Gotchas

Access to Westpac Kubernetes is restricted, so we have to:

- Update securityContext to `runAsUser: 1000` in order to avoid running as root
- Override `kernelCaps: ["SYS_ADMIN"]` with empty array to prevent the error `securityContext.capabilities.add: Invalid value: "SYS_ADMIN": capability may not be added` when Moon spins up pods for a browser
- Add environment variable HOME=/tmp to all browser pods to avoid permission denied errors...
- Automated tests using chromium-based browsers (Edge, Chrome) must provide startup argument of `--no-sandbox` because SYS_ADMIN permission has been removed

The values file controls these settings.
