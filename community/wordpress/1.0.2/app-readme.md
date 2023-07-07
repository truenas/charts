# Wordpress

[Wordpress](https://wordpress.org/) is a web content management system.

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `wordpress` directories.
> Afterward, the `wordpress` container will run as a **non**-root user (`33`).
> Same applies to the `mariadb` container. This will run afterwards as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `mariadb` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `wordpress` and `mariadb` data directories.
