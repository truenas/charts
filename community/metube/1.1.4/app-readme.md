# MeTube

[MeTube](https://github.com/alexta69/metube) is a web GUI for youtube-dl (using the yt-dlp fork) with playlist support.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `MeTube` directories.
> Afterward, the `MeTube` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
