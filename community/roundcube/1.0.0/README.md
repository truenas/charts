# Roundcube

[Roundcube](https://roundcube.net/) is a browser-based multilingual IMAP client with an application-like user interface.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `postgres` directories.
> Afterward, the `postgres` container will run as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `postgres` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `postgres` data directories.
