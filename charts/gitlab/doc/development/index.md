---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Development Guide

Our contribution policies can be found in [CONTRIBUTING.md](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/CONTRIBUTING.md)

Contributing documentation changes to the charts requires only a text editor. Documentation is stored in the [doc/](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/doc/) directory.

## Architecture

Before starting development, it is helpful to review the goals, architecture, and design decisions for the charts.

See [Architecture of Cloud native GitLab Helm charts](../architecture/index.md) for this information.

## Environment setup

See [setting up your development environment](environment_setup.md) to prepare your workstation for charts development.

## Style guide

See the [chart development style guide](style_guide.md) for guidelines and best practices for chart development.

## Writing and running tests

We run several different types of tests to validate the charts work as intended.

### Developing RSpec tests

Unit tests are written in RSpec and stored in the `spec/` directory of the chart repository.

Read the notes on [creating RSpec tests](rspec.md) to validate the
functionality of the chart.

### Running GitLab QA

[GitLab QA](https://gitlab.com/gitlab-org/gitlab-qa) can be used to run integrations and functional tests against a deployed cloud native GitLab installation.

[Read more in the GitLab QA chart docs](gitlab-qa/index.md).

### ChaosKube

ChaosKube can be used to test the fault tolerance of highly available cloud native GitLab installations.

[Read more in the ChaosKube chart docs](chaoskube/index.md).

## Versioning and Release

Details on the version scheme, branching and tags can be found in [release document](release.md).

## Changelog Entries

All `CHANGELOG.md` entries should be created via the [changelog entries](changelog.md) workflow.

## When to fork upstream charts

### No changes, no fork

Let it be stated that any chart that does not require changes to function
for our use *should not* be forked into this repository.

### Guidelines for forking

#### Sensitive information

If a given chart expects that sensitive communication secrets will be presented
from within environment, such as passwords or cryptographic keys, [we prefer to
use initContainers](../architecture/decisions.md#preference-of-secrets-in-initcontainer-over-environment).

#### Extending functionality

There are some cases where it is needed to extend the functionality of a chart in
such a way that an upstream may not accept.

## Handling configuration deprecations

There are times in a development where changes in behavior require a functionally breaking change. We try to avoid such changes, but some items can not be handled without such a change.

To handle this, we have implemented the [deprecations template](deprecations.md). This template is designed to recognize properties that need to be replaced or relocated, and inform the user of the actions they need to take. This template will compile all messages into a list, and then cause the deployment to stop via a `fail` call. This provides a method to inform the user at the same time as preventing the deployment the chart in a broken or unexpected state.

See the documentation of the [deprecations template](deprecations.md) for further information on the design, functionality, and how to add new deprecations.

## Attempt to catch problematic configurations

Due to the complexity of these charts and their level of flexibility, there are some overlaps where it is possible to produce a configuration that would lead to an unpredictable, or entirely non-functional deployment. In an effort to prevent known problematic settings combinations, we have the following two patterns in place:

- We use [schema validations](https://helm.sh/docs/topics/charts/#schema-files) for all
  our sub-charts to ensure the user-specified values meet expectations. See
  [the documentation](validation.md) to learn more.
- We implement template logic designed to detect and warn the user that their
  configuration will not work. See the documentation of the
  [`checkConfig` template](checkconfig.md) for further information on the design and
  functionality, and how to add new configuration checks.

## Verifying registry

In development mode, verifying Registry with Docker clients can be difficult. This is partly due to issues with certificate of
the registry. You can either [add the certificate](https://docs.docker.com/registry/insecure/#use-self-signed-certificates) or
[expose the registry over HTTP](https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry) (see `global.hosts.registry.https`).
Note that adding the certificate is more secure than the insecure registry solution.

Please keep in mind that Registry uses the external domain name of MinIO service (see `global.hosts.minio.name`). You may
encounter an error when using internal domain names, e.g. with custom TLDs for development environment. The common symptom
is that you can log in to the Registry but you can't push or pull images. This is generally because the Registry container(s)
can not resolve the MinIO domain name and find the correct endpoint (you can see the errors in container logs).

## Troubleshooting a development environment

Developers may encounter unique issues while working on new chart features.
[Refer to the troubleshooting guide](troubleshooting.md) for
information if your **_development_** cluster seems to have strange issues.

NOTE:
The troubleshooting steps outlined in the link above are for development
clusters only. Do not use these procedures in a production environment or
data will be lost.
