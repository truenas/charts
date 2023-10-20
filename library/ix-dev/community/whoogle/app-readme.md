# Whoogle

[Whoogle](https://github.com/benbusby/whoogle-search) is a self-hosted, ad-free, privacy-respecting metasearch engine

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Whoogle` directories.
> Afterward, the `Whoogle` container will run as a **non**-root user (`927`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
