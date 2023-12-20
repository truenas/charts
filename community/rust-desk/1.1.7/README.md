# Rust Desk

[Rust Desk](https://rustdesk.com) is an open-source remote desktop, and alternative to TeamViewer.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Rust Desk` directories.
> Afterward, the `Rust Desk` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
