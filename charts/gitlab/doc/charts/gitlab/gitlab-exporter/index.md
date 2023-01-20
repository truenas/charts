---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab-Exporter chart **(FREE SELF)**

The `gitlab-exporter` sub-chart provides Prometheus metrics for GitLab
application-specific data. It talks to PostgreSQL directly to perform
queries to retrieve data for CI builds, pull mirrors, etc. In addition,
it uses the Sidekiq API, which talks to Redis to gather different
metrics around the state of the Sidekiq queues (e.g. number of jobs).

## Requirements

This chart depends on Redis and PostgreSQL services, either as part of
the complete GitLab chart or provided as external services reachable
from the Kubernetes cluster on which this chart is deployed.

## Configuration

The `gitlab-exporter` chart is configured as follows: [Global
Settings](#global-settings) and [Chart Settings](#chart-settings).

## Installation command line options

The table below contains all the possible chart configurations that can be supplied
to the `helm install` command using the `--set` flags.

| Parameter                        | Default               | Description                                    |
| -------------------------------- | --------------------- | ---------------------------------------------- |
| `annotations`                    |                       | Pod annotations                                |
| `common.labels`                  | `{}`                  | Supplemental labels that are applied to all objects created by this chart.  |
| `podLabels`                      |                       | Supplemental Pod labels. Will not be used for selectors. |
| `common.labels`                  |                       | Supplemental labels that are applied to all objects created by this chart. |
| `deployment.strategy`            | `{}`                  | Allows one to configure the update strategy utilized by the deployment |
| `enabled`                        | `true`                | GitLab Exporter enabled flag                   |
| `extraContainers`                |                       | List of extra containers to include            |
| `extraInitContainers`            |                       | List of extra init containers to include       |
| `extraVolumeMounts`              |                       | List of extra volumes mounts to do            |
| `extraVolumes`                   |                       | List of extra volumes to create                |
| `extraEnv`                       |                       | List of extra environment variables to expose  |
| `image.pullPolicy`               | `IfNotPresent`        | GitLab image pull policy                       |
| `image.pullSecrets`              |                       | Secrets for the image repository               |
| `image.repository`               | `registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter` | GitLab Exporter image repository |
| `image.tag`                      |                       | image tag                                      |
| `init.image.repository`          |                       | initContainer image                            |
| `init.image.tag`                 |                       | initContainer image tag                        |
| `metrics.enabled`                | `true`                | Toggle Prometheus metrics exporter             |
| `metrics.port`                   | `9168`                | Listen port for the Prometheus metrics exporter |
| `resources.requests.cpu`         | `75m`                 | GitLab Exporter minimum CPU                    |
| `resources.requests.memory`      | `100M`                | GitLab Exporter minimum memory                 |
| `serviceLabels`                  | `{}`                  | Supplemental service labels                    |
| `service.externalPort`           | `9168`                | GitLab Exporter exposed port                   |
| `service.internalPort`           | `9168`                | GitLab Exporter internal port                  |
| `service.name`                   | `gitlab-exporter`     | GitLab Exporter service name                   |
| `service.type`                   | `ClusterIP`           | GitLab Exporter service type                   |
| `securityContext.fsGroup`        | `1000`                | Group ID under which the pod should be started |
| `securityContext.runAsUser`      | `1000`                | User ID under which the pod should be started  |
| `tolerations`                    | `[]`                  | Toleration labels for pod assignment           |
| `psql.port`                      |                       | Set PostgreSQL server port. Takes precedence over `global.psql.port` |

## Chart configuration examples

### image.pullSecrets

### extraEnv

`extraEnv` allows you to expose additional environment variables in all containers in the pods.

Below is an example use of `extraEnv`:

```yaml
extraEnv:
  SOME_KEY: some_value
  SOME_OTHER_KEY: some_other_value
```

When the container is started, you can confirm that the environment variables are exposed:

```shell
env | grep SOME
SOME_KEY=some_value
SOME_OTHER_KEY=some_other_value
```

`pullSecrets` allows you to authenticate to a private registry to pull images for a pod.

Additional details about private registries and their authentication methods can be
found in [the Kubernetes documentation](https://kubernetes.io/docs/concepts/containers/images/#specifying-imagepullsecrets-on-a-pod).

Below is an example use of `pullSecrets`:

```YAML
image:
  repository: my.image.repository
  pullPolicy: Always
  pullSecrets:
  - name: my-secret-name
  - name: my-secondary-secret-name
```

### annotations

`annotations` allows you to add annotations to the GitLab Exporter pods. For example:

```YAML
annotations:
  kubernetes.io/example-annotation: annotation-value
```

## Global Settings

We share some common global settings among our charts. See the [Globals Documentation](../../globals.md)
for common configuration options, such as GitLab and Registry hostnames.

## Chart Settings

The following values are used to configure the GitLab Exporter pod.

### metrics.enabled

By default, the pod exposes a metrics endpoint at `/metrics`. When
metrics are enabled, annotations are added to each pod allowing a
Prometheus server to discover and scrape the exposed metrics.
