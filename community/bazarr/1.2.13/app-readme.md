# Bazarr

[Bazarr](https://www.bazarr.media/) is a companion application to Sonarr and Radarr. It manages and downloads subtitles based on your requirements.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Bazarr` directories.
> Afterward, the `Bazarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
