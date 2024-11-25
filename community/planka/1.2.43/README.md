# Planka

[Planka](https://github.com/plankanban/planka) is an Elegant open source project tracking

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Planka` directories.
> Afterward, the `Planka` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
