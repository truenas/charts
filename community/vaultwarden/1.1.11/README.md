# Vaultwarden

[Vaultwarden](https://github.com/dani-garcia/vaultwarden) Alternative implementation of the `Bitwarden` server API written in Rust and compatible with upstream Bitwarden clients

> During the installation process, a container will be launched with **root** privileges. This is required
> in order to apply the correct permissions to the `Vaultwarden` data directory. Afterward, the `Vaultwarden` container
> will run as a **non**-root user (default `568`).
> Same applies to the `postgres` container. This will run afterwards as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `postgres` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `Vaultwarden` and `postgres` data directories.

While the option to use `Rocket` for TLS is there, it is not
[recommended](https://github.com/dani-garcia/vaultwarden/wiki/Enabling-HTTPS#via-rocket).
Instead, use a reverse proxy to handle TLS termination.

Using `HTTPS` is **required** for the most of the features to work (correctly).
