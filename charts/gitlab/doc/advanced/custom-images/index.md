---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Bringing your own images

In certain scenarios (i.e. air-gapping), you may want to bring your own images rather than pulling them down from the Internet. This requires specifying your own Docker image registry/repository for each of the charts that make up the GitLab release.

## Default image format

Our default format for the image in most cases includes the full path to the image, excluding the tag:

```yaml
image:
  repository: repo.example.com/image
  tag: custom-tag
```

The end result will be `repo.example.com/image:custom-tag`.

## Example values file

There is an [example values file](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/custom-images/values.yaml) that demonstrates how to configure a custom Docker registry/repository and tag. You can copy relevant sections of this file for your own releases.

NOTE:
Some of the charts (especially third party charts) sometimes have slightly different conventions for specifying the image registry/repository and tag. You can find documentation for third party charts on the [Artifact Hub](https://artifacthub.io/).
