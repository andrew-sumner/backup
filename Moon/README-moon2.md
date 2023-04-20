# Moon

## Introduction

Values for setting up [Moon](https://aerokube.com/moon/latest/) in Kubernetes within Westpac.

## Getting Started

See:
1. https://confluence.westpac.co.nz/display/BUSINESS/Moon for the installation guide.
2. https://github.com/aerokube/charts for the helm chart
3. https://aerokube.com/images/latest/ for updates to the images

## References

https://stash.westpac.co.nz/projects/CLOUD/repos/kubernauts_services
https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/ingress.md  
https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/external_dns.md  
https://stash.westpac.co.nz/projects/CLOUD/repos/knowledgebase/browse/k8s/cert-manager.md  

When new IPs arrive need a dedicated IP.

## Prerequisites
1. [Create CRDs and cluster resources](https://stash.westpac.co.nz/projects/CLOUD/repos/kubernauts_services)
2. Please follow [the instructions](https://confluence.westpac.co.nz/display/BUSINESS/SOPS) to ensure the following tools are installed:
    - Install GPG
    - Install SOPS
    - Install helm-secrets plugin

## Install Moon2

Helm / Kubernetes commands:

```bash
# Install or update helm aerokube repo
helm repo add aerokube https://charts.aerokube.com
helm repo update

# Select the context
kubectl config current-context
kubectl config use-context etdc-test

# Install Moon
helm secrets upgrade --install --skip-crds -n itcrowd-moon moon . -f values2.yaml -f secrets.yaml
```
## Notes

- Render k8s manifests
```bash
helm template --skip-crds -n itcrowd-moon moon . -f values2.yaml
```

- Get the current chart
```bash
helm -n itcrowd-moon list
helm -n itcrowd-moon get values moon
helm -n itcrowd-moon get manifest moon
```

- Check the app and chart versions
```bash
helm show chart aerokube/moon
helm search repo aerokube --versions
```

- Install helm chart with no modifications
```bash
helm upgrade --install -n itcrowd-moon moon aerokube/moon2 -f values2.yaml
```
## Uninstall Moon

```bash
helm -n itcrowd-moon delete moon
```

## Install browser-ops if required
```
helm upgrade --install -n itcrowd-moon browser-ops aerokube/browser-ops -f browser-ops-values.yaml
```
## Gotchas

Access to Westpac Kubernetes is restricted, so we have to:

- Update securityContext to `runAsUser: 1000` in order to avoid running as root
- [Create CRDs and cluster resources](https://stash.westpac.co.nz/projects/CLOUD/repos/kubernauts_services) by a separate pipeline with the admin level of permissions
- Automated tests using chromium-based browsers (Edge, Chrome) must provide startup argument of `--no-sandbox` because SYS_ADMIN permission has been removed

The values file controls these settings.
