---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab with UBI-based images

GitLab offers [Red Hat UBI](https://www.redhat.com/en/blog/introducing-red-hat-universal-base-image)
versions of its images, allowing you to replace standard images with UBI-based
images. These images use the same tag as standard images with `-ubi8` extension.

The GitLab Chart uses third-party images that are not based on UBI. These images
are mostly offer external services to GitLab, such as Redis, PostgreSQL, and so on.
If you wish to deploy a GitLab instance that purely based on UBI you must
disable the internal services, and use external deployments or services.

The services that must be disabled and provided externally are:

- PostgreSQL
- MinIO (Object Store)
- Redis

The services must be disabled are:

- CertManager (Let's Encrypt integration)
- NGINX Ingress
- Prometheus
- Grafana
- GitLab Runner

## Sample values

We provide an example for GitLab Chart values in [`examples/ubi/values.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/ubi/values.yaml)
which can help you to build a pure UBI GitLab deployment.

## Known Limitations

- Currently there is no UBI version of GitLab Runner. Therefore we disable it.
  However, that does not prevent attaching your own runner to your UBI-based
  GitLab deployment.
- GitLab relies on the official image of Docker Registry which is based on `alpine`.
  At the moment we do not maintain or release a UBI-based version of Registry. Since
  this functionality is _crucial_, we do not disable this service.
