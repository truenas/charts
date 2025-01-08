# Unifi Controller

[Unifi Controller](https://github.com/goofball222/unifi) is a network management controller for Unifi Equipment.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Unifi Controller` directories.
> Afterward, the `Unifi Controller` container will run as a **non**-root user (`999`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
