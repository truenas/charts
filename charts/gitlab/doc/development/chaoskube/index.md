---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# ChaosKube

[ChaosKube](https://github.com/linki/chaoskube) is similar to
Netflix's [chaos monkey](https://github.com/Netflix/chaosmonkey) for Kubernetes
clusters. It schedules random termination of pods in order to test the fault tolerance
of a highly available system.

## Why

As a part of our charts development we needed a way to test the fault tolerance
of our deployments.

## How

Using ChaosKube is a manual step we do after our weekly demos. The intended
use case of ChaosKube is to kill pods randomly at random times during a
working day to test the ability to recover. The way we use it is a bit different,
we manually launch ChaosKube in debug mode and manually identify the weak
points of our deployment.

Later, we intend to integrate it into our CI pipeline, so whenever new changes
are rolled out we have a ChaosKube run for that release.

## Usage

The [`deploy_chaoskube.sh`](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/deploy_chaoskube.sh)
installs and unleashes ChaosKube by scheduling a run 10m after installing ChaosKube by default. It also sets up
the needed service account and role if RBAC is enabled.

After you clone the charts repository, to install and unleash ChaosKube, run:

```shell
scripts/deploy_chaoskube.sh up
```

## Configuration

ChaosKube can be configured by editing the `scripts/chaoskube-resources/values.yaml`
file. For more info read the official [ChaosKube docs](https://github.com/linki/chaoskube).

You can also configure the deployment with flags on the script. To find all available options, run:

```shell
scripts/deploy_chaoskube.sh -h
```

Visit the [README's values section](https://github.com/helm/charts/tree/master/stable/chaoskube#configuration) for a full list of options to pass via `--set` arguments.
