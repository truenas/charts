# Homepage

[Homepage](https://github.com/benphelps/homepage) is a modern, secure, highly customizable application dashboard.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Homepage` directories.
> Afterward, the `Homepage` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
