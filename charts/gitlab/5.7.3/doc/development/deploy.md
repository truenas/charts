---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Deploy Development Branch

First ensure that your development environment is set up for charts development.
See the [Development environment setup](environment_setup.md) page for instructions.

Clone the repository, and checkout the branch you want to deploy:

```shell
git clone git@gitlab.com:gitlab-org/charts/gitlab.git
git checkout <BRANCH_NAME>
```

Note that you can test changes to external dependencies by modifying `requirements.yaml`.

It is possible to test external dependencies using a local repository. Use `file://PATH_TO_DEPENDENCY_REPO`
where the path may be relative to the chart path or absolute. For example, if using
`/home/USER/charts/gitlab` as the main checkout and `/home/USER/charts/gitlab-runner`, the
relative path would be `file://../gitlab-runner/` and the absolute path would be
`file:///home/USER/charts/gitlab-runner/`. Pay close attention with absolute paths as it
is very easy to miss the leading slash on the file path.

Other steps from the [installation documentation](../installation/index.md) still apply. The difference is when deploying
a development branch, you need to add additional upstream repositories and update the local dependencies, then pass the local
Git repository location to the Helm command.

From within your Git checkout of the repository, run the following Helm commands to install:

```shell
helm dependency update
helm upgrade --install gitlab . \
  --timeout 600s \
  --set global.image.pullPolicy=Always \
  --set global.hosts.domain=example.com \
  --set global.hosts.externalIP=10.10.10.10 \
  --set certmanager-issuer.email=me@example.com
```
