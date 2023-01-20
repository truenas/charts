---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Quick Start Guide

This guide serves as a concise but complete documentation about how to install the
Cloud Native GitLab chart with default values onto Google Kubernetes Engine (GKE).
For clarity, we focus exclusively on GKE.

## Requirements

In order to complete this guide, you _must have_ the following:

- A domain to which you or your company owns, to which you can add a DNS record.
- A Kubernetes cluster.
- A working installation of `kubectl`.
- A working installation of Helm v3.

### Available Domain

No folks, you can not use `example.com`.

You must have access to an internet-accessible domain to which you can add
a DNS record. This _can be a sub-domain_ such as `poc.domain.com`, but the
Let's Encrypt servers have to be able to resolve the addresses to be able to
issue certificates.

For the sake of this guide, we assume this is in Google's Cloud DNS. Other
services can be used, but are not covered here.

### Getting a Kubernetes cluster

This guide is not intended to cover how to create or obtain a Kubernetes cluster.
We instead refer to the Google [GKE cluster creation guide](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-zonal-cluster).

NOTE:
A cluster with a total of 8vCPU and 30GB of RAM, or more is recommended.

### Installing kubectl

To install kubectl, see the [Kubernetes installation documentation](https://kubernetes.io/docs/tasks/tools/).
The documentation covers most operating systems and the Google
Cloud SDK, which you may have installed during the previous step.

Be sure to configure your `kubectl` to talk to your newly minted cluster, per
Google's documentation:

NOTE:
After you create a cluster, you must [configure kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl#generate_kubeconfig_entry) before you can interact with the cluster from the command line.

### Installing Helm v3

For this guide, we use the latest release of Helm v3 (v3.3.1 or later).
To install Helm, see the [Helm installation instructions](https://helm.sh/docs/intro/install/).

## Adding the GitLab Helm repository

First and foremost, we have to be able to install `gitlab/gitlab`. In order
to do this, we must add the repository to `helm`'s configuration:

```shell
helm repo add gitlab https://charts.gitlab.io/
```

## Installing GitLab

Here's the beauty of what this chart is capable of. One command. Poof! All
of GitLab installed, and configured with SSL.

To configure the chart, you need:

- The domain or subdomain for GitLab to operate under.
- Your email address, so Let's Encrypt can issue a certificate.

To install the chart, run the install command with two
`--set` arguments:

```shell
helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=DOMAIN \
  --set certmanager-issuer.email=me@example.com
```

NOTE:
This step can take several minutes in order for all resources
to be allocated, services to start, and access made available.

Once this step has completed, we can proceed to collect the IP address that has
been dynamically allocated for the installed NGINX Ingress.

## Retrieve the IP address

We can use `kubectl` to fetch the address that has been dynamically been
allocated by GKE to the NGINX Ingress we've just installed and configured as
a part of the GitLab chart.

```shell
kubectl get ingress -lrelease=gitlab
```

This output should look something like the following:

```plaintext
NAME               HOSTS                 ADDRESS         PORTS     AGE
gitlab-minio       minio.domain.tld      35.239.27.235   80, 443   118m
gitlab-registry    registry.domain.tld   35.239.27.235   80, 443   118m
gitlab-webservice  gitlab.domain.tld     35.239.27.235   80, 443   118m
```

Notice there are three entries and they all have the same IP address.
Take this IP address and add it to your DNS for the domain
you have chosen to use. You can add 3 separate records of type `A`, but we
suggest adding a single "wildcard" record for simplicity. In Google Cloud DNS,
this is done by creating an `A` record, but with the name being `*`. We also
suggest you set the TTL to `1` minute instead of `5` minutes.

## Sign in to GitLab

You can access GitLab at `gitlab.domain.tld`. For example, if you set
`global.hosts.domain=my.domain.tld`, then you would visit `gitlab.my.domain.tld`.

To sign in, you must collect the password for the `root` user.
This is automatically generated at installation time, and stored in a Kubernetes
Secret. Let's fetch that password from the secret, and decode it:

```shell
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```

Yes, you read that right, that's `gitlab-gitlab-...`.

We can now sign in to GitLab with username `root`, and the password retrieved.
You can change this password via the user preferences once logged in, we only
generate it so that we can secure the first login on your behalf.

## Troubleshooting

If you experience issues during this guide, here are a few likely items you should
be sure are working:

1. The `gitlab.my.domain.tld` resolves to the IP address of the Ingress you retrieved.
1. If you get a certificate warning, there has been a problem with Let's Encrypt,
   usually related to DNS, or the requirement to retry.

For further troubleshooting tips, see our [troubleshooting](../troubleshooting/index.md) guide.

### Helm install returns `roles.rbac.authorization.k8s.io "gitlab-shared-secrets" is forbidden`

After running:

```shell
helm install gitlab gitlab/gitlab  \
  --set global.hosts.domain=DOMAIN \
  --set certmanager-issuer.email=user@example.com
```

You might see an error similar to:

```shell
Error: failed pre-install: warning: Hook pre-install templates/shared-secrets-rbac-config.yaml failed: roles.rbac.authorization.k8s.io "gitlab-shared-secrets" is forbidden: user "some-user@some-domain.com" (groups=["system:authenticated"]) is attempting to grant RBAC permissions not currently held:
{APIGroups:[""], Resources:["secrets"], Verbs:["get" "list" "create" "patch"]}
```

This means that the `kubectl` context that you are using to connect to the cluster
does not have the permissions needed to create RBAC resources.
