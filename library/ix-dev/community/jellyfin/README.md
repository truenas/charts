# Jellyfin

[Jellyfin](https://jellyfin.org/) is a Free Software Media System that puts you in control of managing and streaming your media.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Jellyfin` directories.
> Afterward, the `Jellyfin` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
