---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# MinIO

[MinIO](https://min.io/) is an object storage server that exposes S3-compatible APIs.

MinIO can be deployed to several different platforms. To launch a new MinIO instance,
follow their [Quickstart Guide](https://docs.min.io/docs/minio-quickstart-guide.html).
Be sure to [secure access to the MinIO server with TLS](https://docs.min.io/docs/how-to-secure-access-to-minio-server-with-tls.html).

To connect GitLab to an external [MinIO](https://min.io/) instance,
first create MinIO buckets for the GitLab application, using the bucket names
in this [example configuration file](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/examples/values-external-objectstorage.yaml).

Using the [MinIO client](https://docs.min.io/docs/minio-client-complete-guide), create the necessary buckets before use:

```shell
mc mb gitlab-registry-storage
mc mb gitlab-lfs-storage
mc mb gitlab-artifacts-storage
mc mb gitlab-uploads-storage
mc mb gitlab-packages-storage
mc mb gitlab-backup-storage
```

Once the buckets have been created, GitLab can be configured to use the MinIO instance.
See example configuration in [`rails.minio.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/rails.minio.yaml) and
[`registry.minio.yaml`](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage/registry.minio.yaml)
in the [examples](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/examples/objectstorage) folder.
