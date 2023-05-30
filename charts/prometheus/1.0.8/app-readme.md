# Prometheus

[Prometheus](https://prometheus.io/) - Monitoring system and time series database.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `prometheus` directories.
> Afterward, the `prometheus` container will run as a **non**-root user (Default: `568`).
> Also an empty configuration file will be created.

The configuration file is located at `/config/prometheus.yml` inside the container.
Data is stored at `/data` inside the container.
