# SABnzbd

[SABnzbd](https://github.com/Sabnzbd/Sabnzbd) is an Open Source Binary Newsreader written in Python.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `SABnzbd` directories.
> Afterward, the `SABnzbd` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
