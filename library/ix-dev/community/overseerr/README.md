# Overseerr

[Overseerr](https://github.com/sct/overseerr) is a free and open source software application for managing requests for your media library. It integrates with your existing services, such as Sonarr, Radarr, and Plex!

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Overseerr` directories.
> Afterward, the `Overseerr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
