---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Configure this chart with External GitLab Pages

This document intends to provide documentation on how to configure this Helm
chart with a GitLab Pages instance, configured outside of the cluster, using an
Omnibus GitLab package.

## Requirements

1. GitLab 13.7 or later.
1. [External Object Storage](../external-object-storage/index.md), as
   recommended for production instances, should be used.
1. Base64 encoded form of a 32-bytes-long API secret key for Pages to interact
   with GitLab Pages.

## Known limitations

1. [GitLab Pages Access Control](https://docs.gitlab.com/ee/user/project/pages/pages_access_control.html)
   is not supported out of the box.

## Configure external GitLab Pages instance

1. [Install GitLab](https://about.gitlab.com/install/) using the Omnibus GitLab
   package.

1. Edit `/etc/gitlab/gitlab.rb` file and replace its contents with the
   following snippet. Update the values below to match your configuration:

   ```ruby
   roles ['pages_role']

   # Root domain where Pages will be served.
   pages_external_url '<Pages root domain>'  # Example: 'http://pages.example.io'

   # Information regarding GitLab instance
   gitlab_pages['gitlab_server'] = '<GitLab URL>'  # Example: 'https://gitlab.example.com'
   gitlab_pages['api_secret_key'] = '<Base64 encoded form of API secret key>'

   # Tell GitLab to fetch configuration regarding domains from GitLab (as
   # opposed to fetch it from `disk`, which is the default)
   gitlab_pages['domain_config_source'] = 'gitlab'
   ```

1. Apply the changes by running `sudo gitlab-ctl reconfigure`.

## Configure the Chart

1. Create a bucket named `gitlab-pages` in the object storage for storing Pages
   deployments.

1. Create a secret `gitlab-pages-api-key` with the Base64 encoded form of API
   secret key as value.

   ```shell
   kubectl create secret generic gitlab-pages-api-key --from-literal="shared_secret=<Base 64 encoded API Secret Key>"
   ```

1. Refer the following configuration snippet and add necessary entries to your
   values file.

   ```yaml
   global:
     pages:
       path: '/srv/gitlab/shared/pages'
       host: <Pages root domain>
       port: '80'  # Set to 443 if Pages is served over HTTPS
       https: false  # Set to true if Pages is served over HTTPS
       artifactsServer: true
       objectStore:
         enabled: true
         bucket: 'gitlab-pages'
       apiSecret:
         secret: gitlab-pages-api-key
         key: shared_secret
     extraEnv:
       PAGES_UPDATE_LEGACY_STORAGE: true  # Bypass automatic disabling of disk storage
   ```

   NOTE: By setting `PAGES_UPDATE_LEGACY_STORAGE` environment variable to true,
   the feature flag `pages_update_legacy_storage` is enabled which deploys Pages
   to local disk. When you migrate to object storage, do remember to remove this
   variable.

1. [Deploy the chart](../../installation/deployment.md#deploy-using-helm)
   using this configuration.
