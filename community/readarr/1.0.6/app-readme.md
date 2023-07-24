# Readarr

[Readarr](https://github.com/Readarr/Readarr) is an ebook and audiobook collection manager for Usenet and BitTorrent users.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Readarr` directories.
> Afterward, the `Readarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
