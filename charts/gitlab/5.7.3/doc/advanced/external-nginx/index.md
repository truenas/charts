---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# External NGINX Ingress Controller

This chart configures `Ingress` resources for use with the official
[NGINX Ingress](https://github.com/kubernetes/ingress-nginx) implementation. The
NGINX Ingress Controller is deployed as a part of this chart. If you want to
reuse an existing NGINX Ingress Controller already available in your cluster,
this guide will help.

## TCP services in the external Ingress Controller

The GitLab Shell component requires TCP traffic to pass through on
port 22 (by default; this can be changed). Ingress does not directly support TCP services, so some additional configuration is necessary. Your NGINX Ingress Controller may have been [deployed directly](https://github.com/kubernetes/ingress-nginx/blob/master/docs/deploy/index.md) (i.e. with a Kubernetes spec file) or through the [official Helm chart](https://github.com/kubernetes/ingress-nginx). The configuration of the TCP pass through will differ depending on the deployment approach.

### Direct deployment

In a direct deployment, the NGINX Ingress Controller handles configuring TCP services with a
`ConfigMap` (see docs [here](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/exposing-tcp-udp-services.md)).
Assuming your GitLab chart is deployed to the namespace `gitlab` and your Helm
release is named `mygitlab`, your `ConfigMap` should be something like this:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-configmap-example
data:
  22: "gitlab/mygitlab-gitlab-shell:22"
```

After you have that `ConfigMap`, you can enable it as described in the NGINX
Ingress Controller [docs](https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/exposing-tcp-udp-services.md)
using the `--tcp-services-configmap` option.

```yaml
args:
  - /nginx-ingress-controller
  - --tcp-services-configmap=gitlab/tcp-configmap-example
```

Finally make sure that the `Service` for your NGINX Ingress Controller is exposing
port 22 in addition to 80 and 443.

### Helm deployment

If you have installed or will install the NGINX Ingress Controller via it's [Helm chart](https://github.com/kubernetes/ingress-nginx), then you will need to add a value to the chart via the command line:

```shell
--set tcp.22="gitlab/mygitlab-gitlab-shell:22"
```

or a `values.yaml` file:

```yaml
tcp:
  22: "gitlab/mygitlab-gitlab-shell:22"
```

The format for the value is the same as describe above in the "Direct Deployment" section.

## Customize the GitLab Ingress options

The NGINX Ingress Controller uses an annotation to mark which Ingress Controller
will service a particular `Ingress` (see [docs](https://github.com/kubernetes/ingress-nginx#annotation-ingressclass)).
You can configure the Ingress class to use with this chart using the
`global.ingress.class` setting. Make sure to set this in your Helm options.

```shell
--set global.ingress.class=myingressclass
```

While not necessarily required, if you're using an external Ingress Controller, you will likely want to
disable the Ingress Controller that is deployed by default with this chart:

```shell
--set nginx-ingress.enabled=false
```

## Custom certificate management

The full scope of your TLS options are documented [elsewhere](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/installation/tls.md).

If you are using an external Ingress Controller, you may also be using an external cert-manager instance
or managing your certificates in some other custom manner. The full documentation around your TLS options is [here](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/installation/tls.md),
however for the purposes of this discussion, here are the two values that would need to be set to disable the cert-manager chart and tell
the GitLab component charts to NOT look for the built in certificate resources:

```shell
--set certmanager.install=false
--set global.ingress.configureCertmanager=false
```
