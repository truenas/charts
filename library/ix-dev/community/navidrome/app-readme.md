# Navidrome

[Navidrome](https://www.navidrome.org/) is a personal streaming service

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Navidrome` directories.
> Afterward, the `Navidrome` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.

Additional configuration options can be defined via environment variables.
See more information on the [Navidrome Documentation](https://www.navidrome.org/docs/usage/configuration-options)
