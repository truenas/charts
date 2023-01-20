---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Cloud Native Chart Beta

We have been working hard on the chart and it's underlying containers, and are excited to reach beta and share it with the GitLab community.

This effort has required extensive changes across the product:

- Support for directly uploading to object storage
- No dependency on shared storage
- New containers for each component of GitLab
- New Helm chart

While much of the underlying work has been completed, there are a few changes that will be arriving after beta has started. This means that there are a few features of GitLab [that may not work as expected](#known-issues-and-limitations).

## Release cadence

During beta we will be releasing a new version of the chart with each new GitLab patch.
In order to maximize our testing opportunity in beta, there will be additional releases between GitLab patches for any chart specific changes that we want to release.

More information on how we are versioning the chart can be found in the [release documentation](../development/release.md).

Along with the issues and merge requests in this repository, a [changelog](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/CHANGELOG.md) is available to more easily follow along with updates.

## Kubernetes deployment support

GitLab development and testing is taking place on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/), however other Kubernetes deployments
should also work. In the event of a specific non-GKE deployment issue, please raise an issue.

We are currently using Kubernetes version 1.8.12 in our automated tests, and 1.9.7 for development.

## Technical support during beta

Before opening an issue please review the [known issues and limitations](#known-issues-and-limitations), and [search](https://gitlab.com/gitlab-org/charts/gitlab/-/issues) to see if a similar issue already exists.

We greatly appreciate the wider testing of the community during beta, and encourage [detailed issues to be reported](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/new) so we can address them.

We welcome any improvements contributed in the form of [Merge Requests](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests).

## Known issues and limitations

The chart and containers are a work in progress, and not all features are fully functional. Below is a list of the known issues and limitations, although it may not be exhaustive. We recommend also reviewing the [open issues](https://gitlab.com/gitlab-org/charts/gitlab/-/issues).

Helm Chart Issues/Limitations:

- No in-cluster HA database: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/48>
- No GitLab Pages support: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/37>
- No GitLab Geo support: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/8>
- No support for incoming email: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/235>
- Does not support running multiple Gitaly servers: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/432>

Limitations planned to be fixed during beta:

- Cannot create a project from a template: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/348>
- Cannot create a new branch from the UI: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/572>
- GitLab project based import/~~export~~:
  - <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/428>
- ~~Backup procedure does not include repositories~~:
  - <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/503> (fixed in `0.3.0`)

Features that are currently out of scope:

- Support for MySQL: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/250>
- Mattermost: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/251>
- Relative URL as the GitLab Endpoint: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/406>

## Path to general availability

Once beta is complete, the next phase will be general availability. Our goals for the charts to be generally available are:

- High availability, with self-healing pods
- Scalable to very large deployments
- Down-time free upgrades
- Production grade monitoring, logging
- Mature support and documentation for common Kubernetes deployment targets, like: on-premise, EKS, AKS, PKS.
- No breaking changes
