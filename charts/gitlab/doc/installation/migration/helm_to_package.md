---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Migrate from the Helm Chart to the Linux package **(FREE SELF)**

To migrate from a Helm installation to a Linux package (Omnibus) installation:

1. Go to the admin area (**{admin}**) and select **Overview > Components** to
   check your current version of GitLab.
1. Prepare a clean machine and
   [install the Linux package](https://docs.gitlab.com/omnibus/manual_install.html)
   that matches your GitLab Helm chart version.
1. [Verify the integrity of Git repositories](https://docs.gitlab.com/ee/administration/raketasks/check.html)
   on your GitLab Helm chart instance before the migration.
1. Create [a backup of your GitLab Helm chart instance](../../backup-restore/backup.md),
   and make sure to [back up the secrets](../../backup-restore/backup.md#backup-the-secrets)
   as well.
1. Back up `/etc/gitlab/gitlab-secrets.json` on your Omnibus GitLab instance.
1. Use the `secrets.yaml` file from your GitLab Helm chart instance to fill
   `/etc/gitlab/gitlab-secrets.json` on the new Omnibus GitLab instance:
    1. In `/etc/gitlab/gitlab-secrets.json`, replace all the secrets in the
       section `gitlab_rails` with the secrets from `secrets.yaml`:
       - Make sure that the values of `secret_key_base`, `db_key_base`, `otp_key_base`, and
         `encrypted_settings_key_base` do not contain line breaks.
       - The values of `openid_connect_signing_key` and `ci_jwt_signing_key` should have `\n`
         instead of line breaks, and the entire value should be in one line, for example:

            ```plaintext
            -----BEGIN RSA PRIVATE KEY-----\nprivatekey\nhere\n-----END RSA PRIVATE KEY-----\n
            ```

    1. Save the file and reconfigure GitLab:

       ```shell
       sudo gitlab-ctl reconfigure
       ```

1. In the Omnibus instance, configure [object storage](https://docs.gitlab.com/ee/administration/object_storage.html),
   and make sure it works by testing LFS, artifacts, uploads, and so on.
1. If you use the Container Registry, [configure its object storage separately](https://docs.gitlab.com/ee/administration/packages/container_registry.html#use-object-storage). It does not support
   the consolidated object storage.
1. Sync the data from your object storage connected to the Helm chart instance with the new storage
   connected to Omnibus GitLab. A couple of notes:

   - For S3-compatible storages, use the `s3cmd` utility to copy the data.
   - If you plan to use an S3-compatible object storage like MinIO with your
     Omnibus GitLab instance, you should configure the options `endpoint`
     pointing to your MinIO and set `path_style` to `true` in
     `/etc/gitlab/gitlab.rb`.
   - You may re-use your old object storage with the new Omnibus GitLab instance. In this case, you
     do not need to sync data between two object storages. However, the storage could be de-provisioned when
     you uninstall GitLab Helm chart if you are using the built-in MinIO instance.

1. Copy the GitLab Helm backup to `/var/opt/gitlab/backups` on your Omnibus GitLab instance, and
   [perform the restore](https://docs.gitlab.com/ee/raketasks/backup_restore.html#restore-for-omnibus-gitlab-installations).
1. After the restore is complete, run the [doctor Rake tasks](https://docs.gitlab.com/ee/administration/raketasks/doctor.html)
   to make sure that the secrets are valid.
1. After everything is verified, you may [uninstall](../../index.md#uninstall)
   the GitLab Helm chart instance.
