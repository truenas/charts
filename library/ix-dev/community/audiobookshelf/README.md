# Audiobookshelf

[Audiobookshelf](https://www.audiobookshelf.org/) is a self-hosted audiobook and podcast server.

> The following applies only when the storage type is set to **ixVolume**
> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Audiobookshelf` directories.
> Afterward, the `Audiobookshelf` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
