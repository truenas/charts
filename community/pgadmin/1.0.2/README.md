# pgAdmin

[pgAdmin](https://github.com/pgadmin-org/pgadmin4) is the most popular and feature rich Open Source administration and development platform for PostgreSQL

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `pgAdmin` directories.
> Afterward, the `pgAdmin` container will run as a **non**-root user (`5050`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
