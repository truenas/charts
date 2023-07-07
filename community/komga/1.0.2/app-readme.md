# Komga

[Komga](https://github.com/gotson/komga) is a free and open source comics/mangas server.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Komga` directories.
> Afterward, the `Komga` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
