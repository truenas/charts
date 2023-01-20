---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the Shared-Secrets Job **(FREE SELF)**

The `shared-secrets` job is responsible for provisioning a variety of secrets
used across the installation, unless otherwise manually specified. This includes:

1. Initial root password
1. Self-signed TLS certificates for all public services: GitLab, MinIO, and Registry
1. Registry authentication certificates
1. MinIO, Registry, GitLab Shell, and Gitaly secrets
1. Redis and PostgreSQL passwords
1. SSH host keys
1. GitLab Rails secret for [encrypted credentials](https://docs.gitlab.com/ee/administration/encrypted_configuration.html)

## Installation command line options

The table below contains all the possible configurations that can be supplied to
the `helm install` command using the `--set` flag:

| Parameter                  | Default             | Description                         |
| -------------------------- | ------------------- | ----------------------------------- |
| `enabled`                  | `true`              | [See Below](#disable-functionality) |
| `env`                      | `production`        | Rails environment                   |
| `podLabels`                |                     | Supplemental Pod labels. Will not be used for selectors. |
| `annotations`              |                     | Supplemental Pod annotations.       |
| `image.pullPolicy`         | `Always`            | Gitaly image pull policy            |
| `image.pullSecrets`        |                     | Secrets for the image repository    |
| `image.repository`         | `registry.gitlab.com/gitlab-org/build/cng/kubectl` | Gitaly image repository |
| `image.tag`                | `1f8690f03f7aeef27e727396927ab3cc96ac89e7` | Gitaly image tag |
| `rbac.create`              | `true`              | Create RBAC roles and bindings      |
| `resources`                |                     | resource requests, limits           |
| `securitContext.fsGroup`   | `65534`             | User ID to mount filesystems as     |
| `securitContext.runAsUser` | `65534`             | User ID to run the container as     |
| `selfsign.caSubject`       | `GitLab Helm Chart` | selfsign CA Subject                 |
| `selfsign.image.repository` | `registry.gitlab.com/gitlab-org/build/cnf/cfssl-self-sign` | selfsign image repository |
| `selfsign.image.pullSecrets` |                   | Secrets for the image repository    |
| `selfsign.image.tag`       |                     | selfsign image tag                  |
| `selfsign.keyAlgorithm`    | `rsa`               | selfsign cert key algorithm         |
| `selfsign.keySize`         | `4096`              | selfsign cert key size              |
| `serviceAccount.enabled`   | `true`              | Define serviceAccountName on job(s) |
| `serviceAccount.create`    | `true`              | Create ServiceAccount               |
| `serviceAccount.name`      | `RELEASE_NAME-shared-secrets` | Service account name to specify on job(s) (and on the serviceAccount itself if `serviceAccount.create=true`) |
| `tolerations`              | `[]`                | Toleration labels for pod assignment|

## Job configuration examples

### tolerations

`tolerations` allow you schedule pods on tainted worker nodes

Below is an example use of `tolerations`:

```yaml
tolerations:
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
- key: "node_label"
  operator: "Equal"
  value: "true"
  effect: "NoExecute"
```

## Disable functionality

Some users may wish to explicitly disable the functionality provided by this job.
To do this, we have provided the `enabled` flag as a boolean, defaulting to `true`.

To disable the job, pass `--set shared-secrets.enabled=false`, or pass the following
in a YAML via the `-f` flag to `helm`:

```yaml
shared-secrets:
  enabled: false
```

NOTE:
If you disable this job, you **must** manually create all secrets,
and provide all necessary secret content. See [installation/secrets](../installation/secrets.md#manual-secret-creation-optional)
for further details.
