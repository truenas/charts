# MinIO

[MinIO](https://min.io) is a High Performance Object Storage released under Apache License v2.0.
It is API compatible with Amazon S3 cloud storage service. Use MinIO to build high performance infrastructure
for machine learning, analytics and application data workloads.

> During the installation process, a container will be launched with **root** privileges. This is required
> in order to apply the correct permissions to the MinIO data directory. Afterward, the `MinIO` container
> will run as a **non**-root user (`568`).
> Same applies to the `postgres` container. This will run afterwards as a **non**-root user (`999`).
> On each upgrade, a container will be launched with **root** privileges in order to apply the correct
> permissions to the `postgres` backups directory. Container that performs the backup will run as a **non**-root user (`999`) afterwards.
> Keep in mind the permissions on the backup directory will be changed to `999:999` on **every** update.
> But will only be changed once for the `MinIO` and `postgres` data directories.

When Multi Mode is enabled and entries contain `://` (url) will enable Host Networking. Regardless of the selection in the `Networking` section.
