# SearXNG

[SearXNG](https://github.com/searxng/searxng) is a privacy-respecting, hackable metasearch engine

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `SearXNG` directories.
> Afterward, the `SearXNG` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
