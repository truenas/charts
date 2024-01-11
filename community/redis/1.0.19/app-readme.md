# Redis

[Redis](https://redis.io/). The open source, in-memory data store used by millions of developers as a database, cache, streaming engine, and message broker.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Redis` directories.
> Afterward, the `Redis` container will run as a **non**-root user (`1001`) and root group.
> All mounted storage(s) will be `chown`ed only if the parent directory does not match `1001` user.
