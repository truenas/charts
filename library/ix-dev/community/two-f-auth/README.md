# 2FAuth

[2FAuth](https://docs.2fauth.app/) is a web based self-hosted alternative to One Time Passcode (OTP) generators like Google Authenticator, designed for both mobile and desktop.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `2FAuth` directories.
> Afterward, the `2FAuth` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the configured user.
