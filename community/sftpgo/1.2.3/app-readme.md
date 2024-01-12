# SFTPGo

[SFTPGo](https://github.com/drakkan/sftpgo) is a fully featured and highly configurable SFTP server with optional HTTP/S, FTP/S and WebDAV support - S3, Google Cloud Storage, Azure Blob

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `SFTPGo` directories.
> Afterward, the `SFTPGo` container will run as a **non**-root user (Default: `568`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
