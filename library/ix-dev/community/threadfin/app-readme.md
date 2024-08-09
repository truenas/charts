# Threadfin

[Threadfin](https://github.com/Threadfin/Threadfin) is a M3U Proxy for Plex DVR and Emby/Jellyfin Live TV. Based on xTeVe.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Threadfin` directories.
> Afterward, the `Threadfin` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
