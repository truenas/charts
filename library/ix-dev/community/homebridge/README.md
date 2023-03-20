# Homebridge

- This container runs as `root` user.

If host networking is enabled, you must disable mDNS on the host.
Without host networking enabled, you might experience **auto** discovery issues.

> For more advanced users, you can attach an external interface and update Homebridge
> configuration file, to use the external interface for mDNS.

When hostNetwork is enabled, NodePort service will switch to ClusterIP to avoid port conflicts.

## To disable mDNS in TrueNAS SCALE.

Navigate to **Network** -> **Global Configuration** -> **Settings**

- Uncheck `mDNS`
- Save
