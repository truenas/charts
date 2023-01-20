---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Configure this chart with External Redis

This document intends to provide documentation on how to configure this Helm chart with an external Redis service.

If you don't have Redis configured, for on-premise or deployment to VM,
consider using our [Omnibus GitLab package](external-omnibus-redis.md).

## Configure the Chart

Disable the `redis` chart and the Redis service it provides, and point the other services to the external service.

You must set the following parameters:

- `redis.install`: Set to `false` to disable including the Redis chart.
- `global.redis.host`: Set to the hostname of the external Redis, can be a domain or an IP address.
- `global.redis.password.enabled`: Set to `false` if the external Redis does not require a password.
- `global.redis.password.secret`: The name of the [secret which contains the token for authentication](../../installation/secrets.md#redis-password).
- `global.redis.password.key`: The key in the secret, which contains the token content.

Items below can be further customized if you are not using the defaults:

- `global.redis.port`: The port the database is available on, defaults to `6379`.

For example, pass these values via Helm's `--set` flag while deploying:

```shell
helm install gitlab gitlab/gitlab  \
  --set redis.install=false \
  --set global.redis.host=redis.example \
  --set global.redis.password.secret=gitlab-redis \
  --set global.redis.password.key=redis-password \
```

If you are connecting to a Redis HA cluster that has Sentinel servers
running, the `global.redis.host` attribute needs to be set to the name of
the Redis instance group (such as `mymaster` or `resque`), as
specified in the `sentinel.conf`. Sentinel servers can be referenced
using the `global.redis.sentinels[0].host` and `global.redis.sentinels[0].port`
values for the `--set` flag. The index is zero based.

## Use multiple Redis instances

GitLab supports splitting several of the resource intensive
Redis operations across multiple Redis instances. This chart supports distributing
those persistence classes to other Redis instances.

More detailed information on configuring the chart for using multiple Redis
instances can be found in the [globals](../../charts/globals.md#multiple-redis-support)
documentation.

## Specify secure Redis scheme (SSL)

To connect to Redis using SSL, use the `rediss` (note the double `s`) scheme parameter:

```shell
--set global.redis.scheme=rediss
```
