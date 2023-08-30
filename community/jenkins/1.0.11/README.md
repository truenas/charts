# Jenkins

[Jenkins](https://www.jenkins.io/). The leading open source automation server, Jenkins provides hundreds of
plugins to support building, deploying and automating any project.

> When application is installed and on each startup, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Jenkins` directories.
> Afterward, the `Jenkins` container will run as a **non**-root user (`1000`).
> All mounted storage(s) will be `chown`ed only if the parent directory does not match the user and group (`1000`).
