# Grafana

[Grafana](https://grafana.com/) is the open source analytics & monitoring solution for every database.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Grafana` directories.
> Afterward, the `Grafana` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.

Additional configuration can be made by adding additional environment variables
Here is the available [configuration documentation](https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/)

Use the following syntax:
`GF_<SECTION-NAME>_<KEY-NAME>`

Example:
`GF_SMTP_ENABLED`
