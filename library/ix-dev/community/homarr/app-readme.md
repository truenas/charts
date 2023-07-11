# Homarr

[Homarr](https://github.com/ajnart/homarr) is a sleek, modern dashboard that puts all of your apps and services at your fingertips.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Homarr` directories.
> Afterward, the `Homarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
