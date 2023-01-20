---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Running GitLab QA

The following documentation is meant to provide instructions for running
[GitLab QA](https://gitlab.com/gitlab-org/gitlab-qa) against a deployed cloud
native GitLab installation. These steps are performed as a part of the
[CI for this project](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/.gitlab-ci.yml)
but manual runs may be requested during development or a demo.

## Preparation

Before running GitLab QA, there are a few things to do.

### Determine running version of GitLab

From your deployed GitLab chart, visit `/admin` and see the Components panel
for the version of GitLab that is running. If this is `X.Y.Z-pre`, then you
will want the `nightly` image. If this is `X.Y.Z-ee`, then you will want this
version of GitLab QA image.

Export `GITLAB_VERSION` based on what you have observed:

```shell
export GITLAB_VERSION=11.0.3-ee
```

or:

```shell
export GITLAB_VERSION=nightly
```

### Install the `gitlab-qa` gem

Ensure you have a functional version of Ruby, preferably of the `2.5` branch.
Install the `gitlab-qa` gem:

```shell
gem install gitlab-qa
```

For more info, see the [GitLab QA documentation](https://gitlab.com/gitlab-org/gitlab-qa#how-can-you-use-it).

### Docker

GitLab QA makes use of Docker, so you will need to have an operational
installation. Ensure that the daemon is running. If you have set `GITLAB_VERSION=nightly`,
pull the GitLab QA nightly image to ensure that the latest nightly is used for
testing, in conjunction with the nightly builds of the CNG containers:

```shell
docker pull gitlab/gitlab-ee-qa:$GITLAB_VERSION
```

### Network access

To run GitLab QA, you will need sustained network access to the deployed instance.
Ensure this by visiting the deployment from any browser, or via cURL.

### Configuration

Items needed for execution, which
[will be set as environment variables](https://gitlab.com/gitlab-org/gitlab-qa#supported-environment-variables):

- `GITLAB_VERSION`: The version of GitLab QA version to run. See [determine running version of GitLab](#determine-running-version-of-gitlab) above.
- `GITLAB_USERNAME`: This will be `root`.
- `GITLAB_PASSWORD`: This will be the password for the `root` user.
- `GITLAB_ADMIN_USERNAME`: This will be `root`.
- `GITLAB_ADMIN_PASSWORD`: This will be the password for the `root` user.
- `GITLAB_URL`: The fully-qualified URL to the deployed instance. This should be
  in the form of `https://gitlab.domain.tld`.
- `EE_LICENSE`: A string containing a GitLab EE license. This can be handled
  via `export EE_LICENSE=$(cat GitLab.gitlab-license)`.
- `GITHUB_ACCESS_TOKEN`: A string containing a valid GitHub Personal Access Token.
  This will be used to test the GitHub importer. For GitLab team members, you can
  find the access token for the `GitLab QA` user in 1password.

Retrieve the above items, and export them as environment variables.

## Execution

Assuming you have set the environment variables from the
[Configuration](#configuration) step, the following command will perform the
tests against the deployed GitLab instance:

```shell
gitlab-qa Test::Instance::Any EE:$GITLAB_VERSION $GITLAB_URL
```

NOTE:
The above command runs with _nightly_ because the containers used as a
part of this chart are currently based on nightly builds of the `master` branches
of `gitlab-(ee|ce)` repositories.
