---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Use the built-in MinIO service for object storage **(FREE SELF)**

This migration guide is for when you migrate from a
[package-based installation](package_to_helm.md) to the Helm chart and you want
to use the built-in MinIO service for object storage. This is better suited
for testing purposes. For production use, you are advised to set up an
[external object storage](../../advanced/external-object-storage/index.md)

The easiest way to figure out the access details to built-in MinIO cluster is to
look at the `gitlab.yml` file that is generated in Sidekiq, Webservice and
Toolbox pods.

To grab it from the Sidekiq pod:

1. Find out the name of the Sidekiq pod:

   ```shell
   kubectl get pods -lapp=sidekiq
   ```

1. Grab the `gitlab.yml` file from Sidekiq pod:

   ```shell
   kubectl exec <sidekiq pod name> -- cat /srv/gitlab/config/gitlab.yml
   ```

1. In the `gitlab.yml` file, there is a section for uploads with details of
   object storage connection. Something similar to the following:

   ```yaml
   uploads:
     enabled: true
     object_store:
     enabled: true
     remote_directory: gitlab-uploads
     direct_upload: true
     background_upload: false
     proxy_download: true
     connection:
       provider: AWS
       region: <S3 region>
       aws_access_key_id: "<access key>"
       aws_secret_access_key: "<secret access key>"
       host: <Minio host>
       endpoint: <Minio endpoint>
       path_style: true
   ```

1. Use this information to
   [configure the object storage](https://docs.gitlab.com/ee/administration/uploads.html#s3-compatible-connection-settings)
   in the `/etc/gitlab/gitlab.rb` file of the package-based deployment.

   NOTE:
   For connecting to the MinIO service from outside the cluster, the
   MinIO host URL alone is enough. Helm charts based installations are
   configured to redirect requests coming to that URL automatically to the
   corresponding endpoint. So, you don't need to set the `endpoint` value
   in the connection settings in `/etc/gitlab/gitlab.rb`.
