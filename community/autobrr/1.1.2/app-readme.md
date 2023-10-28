# Autobrr

[Autobrr](https://github.com/autobrr/autobrr) is the modern download automation tool for torrents and usenet.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Autobrr` directories.
> Afterward, the `Autobrr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
