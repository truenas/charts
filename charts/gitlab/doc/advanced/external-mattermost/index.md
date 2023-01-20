---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Configure This Chart with Mattermost Team Edition

This document describes how to install Mattermost Team Edition Helm Chart in proximity with an existing GitLab Helm Chart deployment.

As the Mattermost Helm Chart is installed in a separate namespace, it is recommended that
`cert-manager` and `nginx-ingress` be configured to manage cluster-wide Ingress and certificate resources. For additional configuration information,
refer to the [Mattermost Helm configuration guide](https://github.com/mattermost/mattermost-helm/tree/master/charts/mattermost-team-edition#configuration).

## Prerequisites

- A running Kubernetes cluster.
- [Helm v3](https://helm.sh/docs/intro/install/)

NOTE:
For the Team Edition you can have just one replica running.

## Deploy the Mattermost Team Edition Helm Chart

Once you have installed the Mattermost Team Edition Helm Chart, you can deploy it using the following command:

```shell
helm repo add mattermost https://helm.mattermost.com
helm repo update
helm upgrade --install mattermost -f values.yaml mattermost/mattermost-team-edition
```

Wait for the pods to run. Then, using the Ingress host you specified in the configuration, access your Mattermost server.

For additional configuration information, refer to the [Mattermost Helm configuration guide](https://github.com/mattermost/mattermost-helm/tree/master/charts/mattermost-team-edition#configuration).
you experience any issues with this, please view the [Mattermost Helm Chart issue repository](https://github.com/mattermost/mattermost-helm/issues) or
the [Mattermost Forum](https://forum.mattermost.org/search?q=helm).

## Deploy GitLab Helm Chart

To deploy the GitLab Helm Chart, follow the instructions described [here](../../index.md).

Here's a light way to install it:

```shell
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=<your-domain> \
  --set global.hosts.externalIP=<external-ip> \
  --set certmanager-issuer.email=<email>
```

- `<your-domain>`: your desired domain, such as `gitlab.example.com`.
- `<external-ip>`: the external IP pointing to your Kubernetes cluster.
- `<email>`: email to register in Let's Encrypt to retrieve TLS certificates.

Once you've deployed the GitLab instance, follow the instructions for the [initial login](../../installation/deployment.md#initial-login).

## Create an OAuth application with GitLab

The next part of the process is setting up the GitLab SSO integration.
To do so, you need to [create the OAuth application](https://docs.mattermost.com/deployment/sso-gitlab.html) to allow Mattermost to use GitLab as the authentication provider.

NOTE:
Only the default GitLab SSO is officially supported. “Double SSO”, where GitLab SSO is chained to other SSO solutions, is not supported. It may be possible to connect
GitLab SSO with AD, LDAP, SAML, or MFA add-ons in some cases, but because of the special logic required they’re not officially
supported and are known not to work on some experiences.

## Troubleshooting

If you are following a process other than the one provided and experience authentication and/or deployment issues,
let us know in the [Mattermost troubleshooting forum](https://mattermost.org/troubleshoot/).
