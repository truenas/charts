# Distribution

[Distribution](https://github.com/distribution/distribution) is a toolkit to pack, ship, store, and deliver container content

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Distribution` directories.
> Afterward, the `Distribution` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
