# TFTP

[TFTP](https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html) is a server for the Trivial File Transfer Protocol.

The app runs as `root` user and drops privileges to `tftp` (9069) user for the TFTP service.

> On every application start, a container will be launched with **root** privileges.
> This will check the parent directory permissions and ownership.
> If there is a mismatch it will apply the correct permissions to the TFTP directories.
> When "Allow Create" is checked, the above container will also check and `chmod` if needed
> to `757` the TFTP directories and to `555` when not checked.
> Afterward, the `TFTP` container will run as a **root** user, dropping privileges
> to `tftp` (9069) user for the TFTP service.
> Note: You need to have configured DHCP server for network boot to work.
