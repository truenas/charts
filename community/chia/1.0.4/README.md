# Chia

This container runs as `root` user.

When a port is set to < 9000. Host Networking is enabled automatically.
> Also NodePort services turn to ClusterIP services, to avoid attempts to bind ports twice.

Key file is stored in `/plots/keyfile` and is generated automatically, **only** if the file does not exist.
If you want to use your own `keyfile`, you can create a file called `keyfile` in the `/plots` directory and it will be used instead.
> When set on `harvester` mode `keys` variable is set to `none` and no generation is performed.
