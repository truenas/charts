---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using NGINX **(FREE SELF)**

We provide a complete NGINX deployment to be used as an Ingress Controller. Not all
Kubernetes providers natively support the NGINX [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls),
to ensure compatibility.

This chart provides two services: `nginx` and `nginx-default-backend`, which are `nginx-ingress-controller`
and `defaultbackend` from the [Google Container Registry](https://gcr.io/google_containers).

NOTE:
Our [fork](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts/nginx-ingress) of the NGINX chart was pulled from
[GitHub](https://github.com/kubernetes/ingress-nginx). See [Our NGINX fork](fork.md) for details on what was modified in our fork.

NOTE:
The version of the NGINX Ingress Helm Chart bundled with the GitLab Helm Charts
has been updated to support Kubernetes 1.22. As a result, the GitLab Helm
Chart can not longer support Kubernetes versions prior to 1.19.

## Configuring NGINX

See [NGINX chart documentation](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/charts/nginx-ingress/README.md#configuration)
for configuration details.

### Global Settings

We share some common global settings among our charts. See the [Globals Documentation](../globals.md)
for common configuration options, such as GitLab and Registry hostnames.

## Configure hosts using the Global Settings

The hostnames for the GitLab Server and the Registry Server can be configured using
our [Global Settings](../globals.md) chart.
