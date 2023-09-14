# Kapowarr

[Kapowarr](https://casvt.github.io/Kapowarr/) is a software to build and manage a comic book library, fitting in the *arr suite of software.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Kapowarr` directories.
> Afterward, the `Kapowarr` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
