# Lidarr

[Lidarr](https://github.com/Lidarr/Lidarr) is a music collection manager for Usenet and BitTorrent users.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Lidarr` directories.
> Afterward, the `Lidarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
