# Node-RED

[Node-RED](https://nodered.org) is a programming tool for wiring together hardware devices, APIs and online services in new and interesting ways.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Node-RED` directories.
> Afterward, the `Node-RED` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
