# PiGallery2

[PiGallery2](https://bpatrik.github.io/pigallery2) is a fast directory-first photo gallery website, with rich UI, optimized for running on low resource servers

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `PiGallery2` directories.
> Afterward, the `PiGallery2` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
