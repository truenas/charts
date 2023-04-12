# Gitea

[Gitea](https://gitea.io/en-us) - Git with a cup of tea

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `gitea` directories.
> Afterward, the `gitea` container will run as a **non**-root user (Default: `568`).
> Same applies to the `postgres` container. This will run afterwards as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `postgres` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `gitea` and `postgres` data directories.

On initial startup a setup wizard will be launched with settings for database, ports and root url prefilled.
Keep them as they are, fill the Administration section and click on `Install Gitea`.
