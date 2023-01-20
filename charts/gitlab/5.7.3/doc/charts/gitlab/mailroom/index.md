---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the Mailroom chart **(FREE SELF)**

The Mailroom Pod handles the ingestion of email into the GitLab application.

## Configuration

```yaml
image:
  repository: registry.gitlab.com/gitlab-org/build/cng/gitlab-mailroom
  # tag: v0.9.1
  pullSecrets: []
  # pullPolicy: IfNotPresent

enabled: true

init:
  image: {}
    # repository:
    # tag:
  resources:
    requests:
      cpu: 50m

# Tolerations for pod scheduling
tolerations: []

podLabels: {}

hpa:
  minReplicas: 1
  maxReplicas: 2
  cpu:
    targetAverageUtilization: 75

  # Note that the HPA is limited to autoscaling/v2beta1
  customMetrics: []

networkpolicy:
  enabled: false
  egress:
    enabled: false
    rules: []
  ingress:
    enabled: false
    rules: []
  annotations: {}

resources:
  # limits:
  #  cpu: 1
  #  memory: 2G
  requests:
    cpu: 50m
    memory: 150M

## Allow to overwrite under which User and Group we're running.
securityContext:
  runAsUser: 1000
  fsGroup: 1000

## Enable deployment to use a serviceAccount
serviceAccount:
  enabled: false
  create: false
  annotations: {}
  ## Name to be used for serviceAccount, otherwise defaults to chart fullname
  # name:
```

| Parameter                            | Description                                      | Default                     |
|--------------------------------------|--------------------------------------------------|-----------------------------|
| `deployment.strategy`                | Allows one to configure the update strategy utilized by the deployment | `{}`  |
| `enabled`                            | Mailroom enablement flag                         | `true`                      |
| `hpa.minReplicas`                    | Minimum number of replicas                       | `1`                         |
| `hpa.maxReplicas`                    | Maximum number of replicas                       | `2`                         |
| `hpa.cpu.targetAverageUtilization`   | Target value of the average of the resource metric | `75`                      |
| `hpa.customMetrics`                  | autoscaling/v2beta1 Metrics contains the specifications for which to use to calculate the desired replica count (overrides the default use of Average CPU Utilization configured in `targetAverageUtilization`) | `[]`  |
| `image.pullPolicy`                   | Mailroom image pull policy                       | `IfNotPresent`              |
| `image.pullSecrets`                  | Mailroom image pull secrets                      |                             |
| `image.repository`                   | Mailroom image repository                        | `registry.gitlab.com/gitlab-org/build/cng/gitlab-mailroom` |
| `image.tag`                          | Mailroom image tag                               | `master`                    |
| `init.image.repository`              | Mailroom init image repository                   |                             |
| `init.image.tag`                     | Mailroom init image tag                          |                             |
| `init.resources`                     | Mailroom init container resource requirements    | `{ requests: { cpu: 50m }}` |
| `podLabels`                          | Labels for running Mailroom Pods                 | `{}`                          |
| `common.labels`                      | Supplemental labels that are applied to all objects created by this chart. | `{}` |
| `resources`                          | Mailroom resource requirements                   | `{ requests: { cpu: 50m, memory: 150M }}` |
| `networkpolicy.annotations`          | Annotations to add to the NetworkPolicy          | `{}`                          |
| `networkpolicy.egress.enabled`       | Flag to enable egress rules of NetworkPolicy     | `false`                     |
| `networkpolicy.egress.rules`         | Define a list of egress rules for NetworkPolicy  | `[]`                          |
| `networkpolicy.enabled`              | Flag for using NetworkPolicy                     | `false`                     |
| `networkpolicy.ingress.enabled`      | Flag to enable `ingress` rules of NetworkPolicy  | `false`                     |
| `networkpolicy.ingress.rules`        | Define a list of `ingress` rules for NetworkPolicy | `[]`                          |
| `securityContext.fsGroup`            | Group ID under which the pod should be started   | `1000`                      |
| `securityContext.runAsUser`          | User ID under which the pod should be started    | `1000`                      |
| `serviceAccount.annotations`         | Annotations for ServiceAccount                   | `{}`                          |
| `serviceAccount.enabled`             | Flag for using ServiceAccount                    | `false`                       |
| `serviceAccount.create`              | Flag for creating a ServiceAccount               | `false`                       |
| `serviceAccount.name`                | Name of ServiceAccount to use                    |                             |
| `tolerations`                        | Tolerations to add to the Mailroom               |                             |

## Incoming email

By default, incoming email is disabled. There are two methods for
reading incoming email:

- [IMAP](#imap)
- [Microsoft Graph](#microsoft-graph)

First, enable it by setting the [common settings](../../../installation/command-line-options.md#common-settings).
Then configure the [IMAP settings](../../../installation/command-line-options.md#imap-settings) or
[Microsoft Graph settings](../../../installation/command-line-options.md#microsoft-graph-settings).

These methods can be configured in `values.yaml`. See the following examples:

- [Incoming email with IMAP](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-incoming-email.yaml)
- [Incoming email with Microsoft Graph](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-msgraph.yaml)

### IMAP

To enable incoming e-mail for IMAP, provide details of your IMAP server
and access credentials using the `global.appConfig.incomingEmail`
settings.

In addition, the [requirements for the IMAP email account](https://docs.gitlab.com/ee/administration/incoming_email.html)
should be reviewed to ensure that the targeted IMAP account can be used
by GitLab for receiving email. Several common email services are also
documented on the same page to aid in setting up incoming email.

The IMAP password will still need to be created as a Kubernetes Secret as
described in the [secrets guide](../../../installation/secrets.md#imap-password-for-incoming-emails).

### Microsoft Graph

See the [GitLab documentation on creating an Azure Active Directory application](https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph).

Provide the tenant ID, client ID, and client secret. You can find details for these settings in the [command line options](../../../installation/command-line-options.md#incoming-email-configuration).

Create a Kubernetes secret containing the client secret as described in the [secrets guide](../../../installation/secrets.md#microsoft-graph-client-secret-for-incoming-emails).

### Reply-by-email

To use the reply-by-email feature, where users can reply to notification emails to
comment on issues and MRs, you need to configure both [outgoing email](../../../installation/command-line-options.md#outgoing-email-configuration)
and incoming email settings.

### Service desk email

By default, the service desk email is disabled.

As with incoming e-mail, enable it by setting the [common settings](../../../installation/command-line-options.md#common-settings-1).
Then configure the [IMAP settings](../../../installation/command-line-options.md#imap-settings-1) or
[Microsoft Graph settings](../../../installation/command-line-options.md#microsoft-graph-settings-1).

These options can also be configured in `values.yaml`. See the following examples:

- [Service desk with IMAP](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-service-desk-email.yaml)
- [Service desk with Microsoft Graph](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/examples/email/values-msgraph.yaml)

Service desk email _requires_ that [Incoming email](#incoming-email) be configured.

#### IMAP

Provide details of your IMAP server and access credentials using the
`global.appConfig.serviceDeskEmail` settings. You can find details for
these settings in the [command line options](../../../installation/command-line-options.md#service-desk-email-configuration).

Create a Kubernetes secret containing IMAP password as described in the [secrets guide](../../../installation/secrets.md#imap-password-for-service-desk-emails).

#### Microsoft Graph

See the [GitLab documentation on creating an Azure Active Directory application](https://docs.gitlab.com/ee/administration/incoming_email.html#microsoft-graph).

Provide the tenant ID, client ID, and client secret using the
`global.appConfig.serviceDeskEmail` settings. You can find details for
these settings in the [command line options](../../../installation/command-line-options.md#service-desk-email-configuration).

You will also have to create a Kubernetes secret containing the client secret
as described in the [secrets guide](../../../installation/secrets.md#imap-password-for-service-desk-emails).
