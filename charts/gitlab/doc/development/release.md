---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Releases

## Chart Versioning

### Major Releases

Major releases are for breaking changes **and** significant milestones in the chart or GitLab release.

We bump the major version number for:

- Significant additions or changes. For example, we add Pages by default or we drop NGINX completely.
- Breaking changes in GitLab or in the charts, requiring manual interaction to upgrade your existing install.
- Major updates in the GitLab image (for example, the release of 12.0.0).

### Minor Releases

Minor releases will iterate with GitLab image minor releases, and at our own discretion for changes here in the chart.

We will bump it for:

- all minor version updates of GitLab
- changes to our default values in the charts that may increase resource usage (addition of subcharts or pods, additional services or ingresses added)
- Other functionality changes that we feel warrants more visibility.

### Patch Releases

Patch releases for changes that are considered to be very stable updates to the previous release. This includes patch release of the GitLab image.

We will bump it for:

- Patch releases of the GitLab image
- Any collection of changes that doesn't cause us to bump the minor or major versions.

### Example release scenarios

| Chart Version | GitLab Version | Release Scenario |
| ------------- | -------------- | ---------------- |
| `0.2.0`       | `11.0.0`       | GitLab 11 release, and Chart beta |
| `0.2.1`       | `11.0.1`       | GitLab patch release |
| `0.2.2`       | `11.0.1`       | Chart changes released |
| `0.2.3`       | `11.0.2`       | GitLab patch release, with some accompanying chart changes |
| `0.3.0`       | `11.1.0`       | GitLab minor release, along with new chart changes |
| `0.4.0`       | `11.1.0`       | Chart change that we feel makes sense to include as a minor version bump |
| `0.2.4`       | `11.0.3`       | Security release |
| ~~`0.3.1`~~   | ~~`11.1.1`~~   | ~~Security release~~ (*1*) |
| `0.4.1`       | `11.1.1`       | Security release (*1*) |
| ...           | ...            | ... |
| `1.0.0`       | `11.x.0`       | GitLab minor release, along with Chart GA |
| `2.0.0`       | `11.x.x`       | Introduced some breaking change to the chart |
| `3.0.0`       | `12.0.0`       | GitLab 12 release |

- (*1*): If we have two chart versions that both would need to be upgraded to the same image version
  for a security release, we will just update the newer one. Otherwise automating release logic will
  be overly complicated. Users can workaround if needed by manually specifying the image version, or
  upgrading their chart.

### Future iteration

While we considered just using the GitLab version as our own, we are not yet in lockstep with GitLab releases to the point where we would make a breaking change here in the chart, and require GitLab to bump the version number to 12 for instance. For now we will move forward with a chart specific version scheme, until we get to the point where we have the charts stable enough that we are comfortable with sharing the same version, and a chart update being a reasonable reason to bump the GitLab core version.

## Branches and Tags

For this chart, we propose to follow the same branching strategy as the other main GitLab components.

- A `master` branch,
- `x-x-stable` branches that we create from master per minor release.
- `x.x.x` tags from those stable branches.

The difference between our branch names, and the other GitLab components, is that we will be using the chart's version in the branch name, rather than the GitLab version.

In general, changes will be merged to master, then cherry-picked into the appropriate branch before release. GitLab image updates will happen as commits in the branches, not in master, as master will follow the latest daily images.

### Example timeline of release actions

Related to releasing using the proposed branching strategy

| Branch       | Tag     | Action       | Details |
| ------------ | ------- | ------------ | ------- |
| `0-2-stable` |         | Branch       | Branch created from master |
|              |         | Image update | GitLab `11.0.0-rcX` image used |
|              |         | Pick         | Additional changes from master picked into branch |
|              |         | Image update | GitLab `11.0.0` image used |
|              | `0.2.0` | Tag          | Chart `0.2.0` released |
|              |         | Pick         | Fixes from master picked into branch |
|              |         | Image update | GitLab `11.0.1` image used |
|              | `0.2.1` | Tag          | Chart `0.2.1` released |
| `0-3-stable` |         | Branch       | Branch created from master |
|              |         | Image update | GitLab `11.1.0-rc1` image used |
| `0-2-stable` |         | Image update | GitLab `11.0.2` image used |
|              | `0.2.2` | Tag          | Chart  `0.2.2` released |
| `0-3-stable` |         | Pick         | Fixes from master picked into branch |
|              |         | Image update | GitLab `11.1.0` image used |
|              | `0.3.0` | Tag          | Chart `0.3.0` released |

## Releasing the chart

Releasing a new version of the chart is handled by the Helm release tasks in the [release tools repository](https://gitlab.com/gitlab-org/release-tools)

By default, this task will be automatically run from CI when a new release image is tagged in the [CNG image repository](https://gitlab.com/gitlab-org/build/CNG)

> Currently the `helm-release-tools` branch from the release tools repository is used to release the chart

### Development builds

Development chart versions are being built with every merge to `master`.

It is possible to track current non-production "development" releases of Helm chart by using `devel` channel:

```shell
helm repo add gitlab-devel https://gitlab.com/api/v4/projects/3828396/packages/helm/devel
```

and using `--devel` option for `helm` pointing to a specific release:

```shell
helm install --devel --version 1.2.3-4567 gitlab-devel/gitlab
```

to list available `devel` versions:

```shell
helm search repo gitlab-devel --devel
```

### Manually releasing the chart

Before manually releasing the chart, ensure all the chart changes you want from `master` have been picked into the
stable branch for the version you will release.

For example, if you want to release version `0.2.1` of the charts, the changes will need to be in `0-2-stable`

A ChatOps command exists to tag a release. Run the following command in the
relevant release Slack channel (such as `#f_release_12_4`)

```plaintext
/chatops run helm tag <charts version> <GitLab version>
```

You can also do it manually, without using the ChatOps command as follows:

1. checkout and setup the [release tools repository](https://gitlab.com/gitlab-org/release-tools).

   ```shell
   git clone git@gitlab.com:gitlab-org/release-tools.git
   bundle install
   ```

1. Then run the appropriate Helm release task:

   - When you want to release without changing the GitLab app version, call the release task with the new chart version (such as `0.2.1`)
     - `bundle exec rake release:helm:tag[0.2.1]`

   - When you want to release and change both the chart version and the app version (such as `0.2.1` with GitLab `11.0.1`)
     - `bundle exec rake release:helm:tag[0.2.1,11.0.1]`

    > You can run the script in dry-run mode which prevents pushes by setting `TEST=true` in your environment
