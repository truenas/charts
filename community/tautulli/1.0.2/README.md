# Tautulli

[Tautulli](https://tautulli.com/) is a python based web application for monitoring, analytics and notifications for Plex Media Server.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Tautulli` directories.
> Afterward, the `Tautulli` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
