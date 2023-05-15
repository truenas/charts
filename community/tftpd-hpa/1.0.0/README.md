# TFTP

[TFTP](https://manpages.debian.org/testing/tftpd-hpa/tftpd.8.en.html) is a server for the Trivial File Transfer Protocol.

The app runs as `root` user and drops privileges to `tftp` (9069) user for the TFTP service.

> On every application start, a container will be launched with **root** privileges.
> This will check the parent directory permissions and ownership.
> If there is a mismatch it will apply the correct permissions to the TFTP directories.
> Additionally, if "Allow Create" is checked, the above container will also `chmod`
> to `757` the TFTP directories.
> Afterward, the `TFTP` container will run as a **root** user, dropping privileges
> to `tftp` (9069) user for the TFTP service.
> Note: You need to have configured DHCP server for network boot to work.
