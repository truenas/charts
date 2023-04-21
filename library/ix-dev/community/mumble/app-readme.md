# Mumble

[Mumble](https://www.mumble.info/) is an Open Source, Low Latency, High Quality Voice Chat Home Downloads Documentation Blog Contribute About

> When application is installed, a container will be launched with **root** privileges.
> This is required in order to apply the correct permissions to the `Mumble` directories.
> Afterward, the `Mumble` container will run as a **non**-root user (`1000`, Cannot change).

You can change the server configuration by adding additional environment variables.
Prefix the configuration variable with `MUMBLE_CONFIG_` and it will be added to the configuration file.
View the [Mumble Configuration File](https://wiki.mumble.info/wiki/Murmur.ini) for more information.

For example you can set `autobanAttempts` like this:

- Name: `MUMBLE_CONFIG_autobanAttempts`
- Value: `5`
