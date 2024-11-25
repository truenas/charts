# Homer

[Homer](https://github.com/bastienwirtz/homer) is a dead simple static HOMepage for your servER to keep your services on hand, from a simple yaml configuration file.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Homer` directories.
> Afterward, the `Homer` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
