# Jellyseerr

[Jellyseerr](https://github.com/Fallenbagel/jellyseerr) is a free and open source software application for managing requests for your media library.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Jellyseerr` directories.
> Afterward, the `Jellyseerr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
