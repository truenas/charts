---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab Runner chart **(FREE SELF)**

The GitLab Runner subchart provides a GitLab Runner for running CI jobs. It is enabled by default and should work out of the box with support for caching using s3 compatible object storage.

## Requirements

This chart depends on the shared-secrets Job to populate its `registrationToken` for automatic registration. If you intend to run this chart as a stand-alone chart with an existing GitLab instance then you will need to manually set the `registrationToken` in the `gitlab-runner` secret to be equal to that displayed by the running GitLab instance.

## Configuration

There are no required settings, it should work out of the box if you deploy all of the charts together.

## Deploying a stand-alone runner

By default we do infer `gitlabUrl`, automatically generate a registration token, and generate it through the `migrations` chart. This behavior will not work if you intend to deploy it with a running GitLab instance.

In this case you will need to set `gitlabUrl` value to be the URL of the running GitLab instance. You will also need to manually create `gitlab-runner` secret and fill it with the `registrationToken` provided by the running GitLab.

## Using Docker-in-Docker

In order to run Docker-in-Docker, the runner container needs to be privileged to have access to the needed capabilities. To enable it set the `privileged` value to `true`. See the [upstream documentation](https://docs.gitlab.com/runner/install/kubernetes.html#running-docker-in-docker-containers-with-gitlab-runners) in regards to why this is does not default to `true`.

### Security concerns

Privileged containers have extended capabilities, for example they can mount arbitrary files from the host they run on. Make sure to run the container in an isolated environment such that nothing important runs beside it.

## Installation command line options

| Parameter                                      | Description                                | Default                               |
| ---------------------------------------------- | ------------------------------------------ | ------------------------------------- |
| `gitlab-runner.image`                          | Runner image                               | `gitlab/gitlab-runner:alpine-v10.5.0` |
| `gitlab-runner.gitlabUrl`                      | URL that the Runner uses to register to GitLab Server                | GitLab external URL                   |
| `gitlab-runner.install`                        | Install the `gitlab-runner` chart          | `true`                                |
| `gitlab-runner.imagePullPolicy`                | Image pull policy                          | `IfNotPresent`                        |
| `gitlab-runner.init.image.repository`          | `initContainer` image                      |                                       |
| `gitlab-runner.init.image.tag`                 | `initContainer` image tag                  |                                       |
| `gitlab-runner.pullSecrets`                    | Secrets for the image repository           |                                       |
| `gitlab-runner.unregisterRunners`              | Unregister all runners before termination  | `true`                                |
| `gitlab-runner.concurrent`                     | Number of concurrent jobs                  | `20`                                  |
| `gitlab-runner.checkInterval`                  | Polling interval                           | `30s`                                 |
| `gitlab-runner.rbac.create`                    | Whether to create RBAC service account     | `true`                                |
| `gitlab-runner.rbac.clusterWideAccess`         | Deploy containers of jobs cluster-wide     | `false`                               |
| `gitlab-runner.rbac.serviceAccountName`        | Name of the RBAC service account to create | `default`                             |
| `gitlab-runner.runners.privileged`             | Run in privileged mode, needed for `dind`  | `false`                               |
| `gitlab-runner.runners.cache.secretName`       | Secret to access key and secret key from   | `gitlab-minio`                        |
| `gitlab-runner.runners.config`                 | Runner configuration as string             | See [below](#default-runner-configuration)|
| `gitlab-runner.resources.limits.cpu`           | Runner CPU limit                           |                                       |
| `gitlab-runner.resources.limits.memory`        | Runner memory limit                        |                                       |
| `gitlab-runner.resources.requests.cpu`         | Runner requested CPU                       |                                       |
| `gitlab-runner.resources.requests.memory`      | Runner requested memory                    |                                       |

## Default runner configuration

The default runner configuration used in the GitLab chart has been customized to use the included MinIO for cache by default. If you are setting the runner `config` value, you will need to also configure your own cache configuration.

```yaml
gitlab-runner:
  runners:
    config: |
      [[runners]]
        [runners.kubernetes]
        image = "ubuntu:18.04"
        {{- if .Values.global.minio.enabled }}
        [runners.cache]
          Type = "s3"
          Path = "gitlab-runner"
          Shared = true
          [runners.cache.s3]
            ServerAddress = {{ include "gitlab-runner.cache-tpl.s3ServerAddress" . }}
            BucketName = "runner-cache"
            BucketLocation = "us-east-1"
            Insecure = false
        {{ end }}
```

## Chart configuration examples

Runners configuration to use only custom nameservers (exclude any cluster or host nameservers):

```yaml
gitlab-runner:
  runners:
    config: |
      [[runners]]
        [runners.kubernetes]
          image = "ubuntu:18.04"
          dns_policy = "none"
        [runners.kubernetes.dns_config]
          nameservers = ["8.8.8.8"]
```

See the [Runner Chart additional configuration](https://docs.gitlab.com/runner/install/kubernetes.html#additional-configuration).
