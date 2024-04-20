# Tailscale

[Tailscale](https://tailscale.com) Secure remote access to shared resources

- When `Userspace` is **disabled**, `Tailscale` will run as root, with `/dev/net/tun` device mounted from the host.
- When `Userspace` is **enabled**, `Tailscale` will run as a non-root user.
