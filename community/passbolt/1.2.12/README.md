# Passbolt

[Passbolt](https://www.passbolt.com) is a security-first, open source password manager

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Passbolt` directories.
> Afterward, the `Passbolt` container will run as a **non**-root user (`33`).
> Same applies to the `mariadb` container. This will run afterwards as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `mariadb` **backups** directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `Passbolt` and `mariadb` data directories.

## Register admin user

Connect to the container's shell
CD ..  several time to move to the level you see 
![Captura de tela 2024-01-09 101333](https://github.com/user-attachments/assets/f981750f-5fb9-405c-a1c2-73130436d058)

and run the following command replacing the
values (`user@example.com`, `first_name`, `last_name`) with your own values.

```shell
/usr/share/php/passbolt/bin/cake passbolt register_user -r admin -u user@example.com -f first_name -l last_name
```
then paste the link in your browser and finish the first steps.
