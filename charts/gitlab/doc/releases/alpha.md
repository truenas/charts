---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Cloud Native Chart Alpha

> **Outdated**:
The charts are now in beta. See the [beta documentation](beta.md) for more information

We have been working hard on the chart and it's underlying containers, and are excited to reach alpha and share it with the GitLab community.

This effort has required extensive changes across the product:

- Support for directly uploading to object storage
- No dependency on shared storage
- New containers for each component of GitLab
- New Helm chart

While much of the underlying work has been completed, there are a few changes that will be arriving after alpha has started. This means that there are a few features of GitLab [that may not work as expected](#known-issues-and-limitations).

## Release cadence

In order to maximize our testing opportunity in alpha, the chart and containers will be rebuilt off `master` as changes are merged. This means that fixes and improvements will be available immediately, instead of waiting for a specific release.

Along with the issues and merge requests in this repository, a [changelog](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/289) is being made available to more easily follow along with updates throughout the alpha period.

## Kubernetes deployment support

GitLab development and testing is taking place on [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine/), however other Kubernetes deployments
should also work. In the event of a specific non-GKE deployment issue, please raise an issue.

We are currently using Kubernetes version 1.8.7 for development. We plan to announce the minimum required Kubernetes version during beta.

## GitLab Enterprise Edition

During alpha, GitLab Enterprise Edition is required while we [bring object storage support to Community Edition](https://gitlab.com/gitlab-org/gitlab-foss/-/issues/40781). GitLab EE offers same functionality as GitLab CE when no license is supplied.

We will be adding support for GitLab Community Edition before making these charts generally available.

## Technical support during alpha

Technical support is limited during this alpha phase. Due to the in-development nature, standard GitLab support will not be able to assist.

Before opening an issue please review the [known issues and limitations](#known-issues-and-limitations), and [search](https://gitlab.com/gitlab-org/charts/gitlab/-/issues) to see if a similar issue already exists.

We greatly appreciate the wider testing of the community during alpha, and encourage [detailed issues to be reported](https://gitlab.com/gitlab-org/charts/gitlab/-/issues/new) so we can address them. However we might not be able to provide support for every user request.

We also reserve the right to close issues without providing a reason. Issues can accumulate quickly and we need to spend more time moving the charts forward than doing issue triage.

We welcome any improvements contributed in the form of [Merge Requests](https://gitlab.com/gitlab-org/charts/gitlab/-/merge_requests).

## Known issues and limitations

The chart and containers are a work in progress, and not all features are fully functional. Below is a list of the known issues and limitations, although it may not be exhaustive. We recommend also reviewing the [open issues](https://gitlab.com/gitlab-org/charts/gitlab/-/issues).

Helm Chart Issues/Limitations:

- No in-cluster HA database: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/48>
- No backup/restore procedure: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/28>
- No update procedures, or support for no-downtime upgrades: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/238>
- No support for changing/migrating your storage capacity/options after installation: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/233>
- No GitLab Pages support: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/37>
- No Monitoring support: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/29>
- No support for incoming email: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/235>
- Limited support for customizing GitLab options: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/236>
- CI traces are not persisted: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/245>
- No support for scaling Unicorn separate from workhorse: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/61>
- GitLab maintenance Rake tasks won't work in k8s environments
- No guarantees on safe pod shutdown: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/239>

Features that are currently out of scope:

- Support for MySQL: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/250>
- Mattermost: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/251>
- Relative URL as the GitLab Endpoint: <https://gitlab.com/gitlab-org/charts/gitlab/-/issues/406>

## Path to beta and general availability

The next phase in the chart lifecycle after alpha will be a beta phase. Our goals for entering beta are:

- All features of GitLab are fully functional
- Backup and restore are supported
- Upgrades are supported
- Object storage support for S3 compatible interfaces
- No expected breaking changes
- Releases are versioned

Once beta is complete, the next phase will be general availability. Our goals for the charts to be generally available are:

- High availability, with self-healing pods
- Scalable to very large deployments
- Down-time free upgrades
- Production grade monitoring, logging
- Mature support and documentation for common Kubernetes deployment targets, like: on-premise, EKS, AKS, PKS.
- No breaking changes
