---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# TLS options **(FREE SELF)**

This chart is capable of doing TLS termination using the NGINX Ingress Controller. You have the choice of how to
acquire the TLS certificates for your deployment. Extensive details can be found in [global Ingress settings](../charts/globals.md#configure-ingress-settings).

## Option 1: cert-manager and Let's Encrypt

Let’s Encrypt is a free, automated, and open Certificate Authority. Certificates can be automatically requested
using various tools. This chart comes ready to integrate with a popular choice [cert-manager](https://github.com/jetstack/cert-manager).

*If you are already using cert-manager*, you can use `global.ingress.annotations` to configure [appropriate annotations](https://cert-manager.io/docs/usage/ingress/#supported-annotations) for your cert-manager deployment.

*If you don't already have cert-manager installed in your cluster*, you can install and configure it as a dependency of this chart.

### Internal cert-manager and Issuer

```shell
helm repo update
helm dep update
helm install gitlab gitlab/gitlab \
  --set certmanager-issuer.email=you@example.com
```

Installing `cert-manager` is controlled by the `certmanager.install` setting, and using it in the charts is controlled by the
`global.ingress.configureCertmanager` setting. Both of these are `true` by default, so only the issuer email needs to be
provided by default.

### External cert-manager and internal Issuer

It is possible to make use of an external `cert-manager` but provide an Issuer as a part of this chart.

```shell
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set certmanager-issuer.email=you@example.com \
  --set global.ingress.annotations."kubernetes\.io/tls-acme"=true
```

### External cert-manager and Issuer (external)

To make use of an external `cert-manager` and `Issuer` resource you must provide several items, so that self-signed certificates
are not activated.

1. Annotations to activate the external `cert-manager` (see [documentation](https://cert-manager.io/docs/usage/ingress/#supported-annotations) for further details)
1. Names of TLS secrets for each service (this deactivates [self-signed behaviors](#option-4-use-auto-generated-self-signed-wildcard-certificate))

```shell
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.annotations."kubernetes\.io/tls-acme"=true \
  --set gitlab.webservice.ingress.tls.secretName=RELEASE-gitlab-tls \
  --set registry.ingress.tls.secretName=RELEASE-registry-tls \
  --set minio.ingress.tls.secretName=RELEASE-minio-tls
```

## Option 2: Use your own wildcard certificate

Add your full chain certificate and key to the cluster as a `Secret`, e.g.:

```shell
kubectl create secret tls <tls-secret-name> --cert=<path/to-full-chain.crt> --key=<path/to.key>
```

Include the option to

```shell
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.tls.secretName=<tls-secret-name>
```

### Use AWS ACM to manage certificates

If you are using AWS ACM to create your wildcard certificate, it is not possible to specify it via secret because ACM certificates cannot be downloaded.
Instead, specify them via  `nginx-ingress.controller.service.annotations`:

```yaml
nginx-ingress:
  controller:
    service:
      annotations:
        ...
        service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:{region}:{user id}:certificate/{id}
```

## Option 3: Use individual certificate per service

Add your full chain certificates to the cluster as secrets, and then pass those secret names to each Ingress.

```shell
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set global.ingress.tls.enabled=true \
  --set gitlab.webservice.ingress.tls.secretName=RELEASE-gitlab-tls \
  --set registry.ingress.tls.secretName=RELEASE-registry-tls \
  --set minio.ingress.tls.secretName=RELEASE-minio-tls
```

NOTE:
If you are configuring your GitLab instance to talk with other services, it may be necessary to [provide the certificate chains](../charts/globals.md#custom-certificate-authorities) for those services to GitLab through the Helm chart as well.

## Option 4: Use auto-generated self-signed wildcard certificate

These charts also provide the capability to provide a auto-generated self-signed wildcard certificate.
This can be useful in environments where Let's Encrypt is not an option, but security via SSL is still
desired. This functionality is provided by the [shared-secrets](../charts/shared-secrets.md) job.

> **Note**: The `gitlab-runner` chart does not function properly with self-signed certificates. We recommend
disabling it, as shown below.

```shell
helm install gitlab gitlab/gitlab \
  --set certmanager.install=false \
  --set global.ingress.configureCertmanager=false \
  --set gitlab-runner.install=false
```

The `shared-secrets` job will then produce a CA certificate, wildcard certificate, and a certificate chain
for use by all externally accessible services. The secrets containing these will be `RELEASE-wildcard-tls`,
`RELEASE-wildcard-tls-ca`, and `RELEASE-wildcard-tls-chain`. The `RELEASE-wildcard-tls-ca` contains the public
CA certificate that can be distributed to users and systems that will access the deployed GitLab instance.
The `RELEASE-wildcard-tls-chain` contains both the CA certificate and the wildcard certificate which you can
also use directly for GitLab Runner via `gitlab-runner.certsSecretName=RELEASE-wildcard-tls-chain`.

## TLS requirement for GitLab Pages

For [GitLab Pages with TLS support](https://docs.gitlab.com/ee/administration/pages/#wildcard-domains-with-tls-support),
a wildcard certificate applicable for `*.<pages domain>` (default value of
`<pages domain>` is `pages.<base domain>`) is required.

Because a wild card certificate is required, it can not be automatically created
by cert-manager and Let's Encrypt. cert-manager is therefore by default disabled
for GitLab Pages (via `gitlab-pages.ingress.configureCertmanager`), so you will
have to provide your own k8s Secret containing a wild card certificate. If you
have an external cert-manager configured using `global.ingress.annotations`, you
probably also want to override such annotations in
`gitlab-pages.ingress.annotations`.

By default, the name of this secret is `<RELEASE>-pages-tls`. A different name
can be specified using the `gitlab.gitlab-pages.ingress.tls.secretName` setting:

```shell
helm install gitlab gitlab/gitlab \
  --set global.pages.enabled=true \
  --set gitlab.gitlab-pages.ingress.tls.secretName=<secret name>
```

## Troubleshooting

This section contains possible solutions for problems you might encounter.

### SSL termination errors

If you are using Let's Encrypt as your TLS provider and you are facing certificate-related errors, you have a few options to debug this:

1. Check your domain with [letsdebug](https://letsdebug.net/) for any possible errors.
1. If letsdebug returns not errors, see if there's a problem related to cert-manager:

   ```shell
   kubectl describe certificate,order,challenge --all-namespaces
   ```

   If you see any errors, try removing the certificate object to force requesting a new one.
1. If nothing of the above works, consider reinstalling the cert-manager.
