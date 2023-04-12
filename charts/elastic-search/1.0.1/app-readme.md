# Elastic Search

> During the installation process, a container will be launched with **root** privileges. This is required
> in order to apply the correct permissions to the `Elastic Search` data directory. Afterward, the `Elastic Search` container
> will run as a **non**-root user (default `568`).

If you want to apply additional configuration you can by using additional environment variables.

See the [Elastic Search documentation](https://www.elastic.co/guide/en/elasticsearch/reference/master/docker.html#docker-configuration-methods)
for more information.
