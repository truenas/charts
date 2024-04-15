# Invidious

[Invidious](https://invidious.io/) is an alternative front-end to YouTube.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `postgres` directories.
> Afterward, the `postgres` container will run as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `postgres` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `postgres` data directories.

Additional configuration can be specified

- Via [environment variables](https://github.com/iv-org/invidious/pull/1702)
- By editing the file `/config/config.yaml` (see [example](https://github.com/iv-org/invidious/blob/master/config/config.example.yml))
