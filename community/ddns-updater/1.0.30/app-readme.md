# DDNS Updater

[DDNS Updater](https://github.com/qdm12/ddns-updater) is a lightweight universal DDNS Updater with web UI

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `DDNS Updater` directories.
> Afterward, the `DDNS Updater` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
