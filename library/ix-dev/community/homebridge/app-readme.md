# Homebridge

- This container runs as `root` user.
- HostNetwork is always enabled.
- `mDNS` must be disabled on the host.

Disable mDNS in TrueNAS SCALE:
> **Network** -> **Global Configuration** -> **mDNS**: `uncheck`
