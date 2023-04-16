# Radarr

[Radarr](https://github.com/Radarr/Radarr) is a movie collection manager for Usenet and BitTorrent users.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Radarr` directories.
> Afterward, the `Radarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
