---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Installation command line options **(FREE SELF)**

The tables below contain all the possible charts configurations that can be supplied
to the `helm install` command using the `--set` flags.

The source of the default `values.yaml` file can be found [here](https://gitlab.com/gitlab-org/charts/gitlab/-/blob/master/values.yaml).
These contents change over releases, but you can use Helm itself to retrieve these on a per-version basis:

```shell
helm inspect values gitlab/gitlab
```

## Basic configuration

| Parameter                                      | Description                                                                                 | Default                                       |
|------------------------------------------------|---------------------------------------------------------------------------------------------|-----------------------------------------------|
| `gitlab.migrations.initialRootPassword.key`    | Key pointing to the root account password in the migrations secret                          | `password`                                    |
| `gitlab.migrations.initialRootPassword.secret` | Global name of the secret containing the root account password                              | `{Release.Name}-gitlab-initial-root-password` |
| `global.gitlab.license.key`                    | Key pointing to the Enterprise license in the license secret                                | `license`                                     |
| `global.gitlab.license.secret`                 | Global name of the secret containing the Enterprise license                                 | _none_                                        |
| `global.application.create`                    | Create an [Application resource](https://github.com/kubernetes-sigs/application) for GitLab | `false`                                       |
| `global.edition`                               | The edition of GitLab to install. Enterprise Edition (`ee`) or Community Edition (`ce`)     | `ee`                                          |
| `global.gitaly.enabled`                        | Gitaly enable flag                                                                          | true                                          |
| `global.hosts.domain`                          | Domain name that will be used for all publicly exposed services                             | Required                                      |
| `global.hosts.externalIP`                      | Static IP to assign to NGINX Ingress Controller                                             | Required                                      |
| `global.hosts.ssh`                             | Domain name that will be used for Git SSH access                                            | `gitlab.{global.hosts.domain}`                |
| `global.imagePullPolicy`                       | DEPRECATED: Use `global.image.pullPolicy` instead                                           | `IfNotPresent`                                |
| `global.image.pullPolicy`                      | Set default imagePullPolicy for all charts                                                  | _none_ (default behavior is `IfNotPresent`)   |
| `global.image.pullSecrets`                     | Set default imagePullSecrets for all charts (use a list of `name` and value pairs)          | _none_                                        |
| `global.minio.enabled`                         | MinIO enable flag                                                                           | `true`                                        |
| `global.psql.host`                             | Global hostname of an external psql, overrides subcharts' psql configuration                | _Uses in-cluster non-production PostgreSQL_   |
| `global.psql.password.key`                     | Key pointing to the psql password in the psql secret                                        | _Uses in-cluster non-production PostgreSQL_   |
| `global.psql.password.secret`                  | Global name of the secret containing the psql password                                      | _Uses in-cluster non-production PostgreSQL_   |
| `global.registry.bucket`                       | registry bucket name                                                                        | `registry`                                    |
| `global.service.annotations`                   | Annotations to add to every `Service`                                                       | {}                                            |
| `global.deployment.annotations`                | Annotations to add to every `Deployment`                                                    | {}                                            |
| `global.time_zone`                             | Global time zone                                                                            | UTC                                           |

## TLS configuration

| Parameter                               | Description                                                       | Default |
|-----------------------------------------|-------------------------------------------------------------------|---------|
| `certmanager-issuer.email`              | Email for Let's Encrypt account                                   | false   |
| `gitlab.webservice.ingress.tls.secretName` | Existing `Secret` containing TLS certificate and key for GitLab | _none_ |
| `gitlab.webservice.ingress.tls.smartcardSecretName` | Existing `Secret` containing TLS certificate and key for the GitLab smartcard auth domain | _none_ |
| `global.hosts.https`                    | Serve over https                                                  | true    |
| `global.ingress.configureCertmanager`   | Configure cert-manager to get certificates from Let's Encrypt     | true    |
| `global.ingress.tls.secretName`         | Existing `Secret` containing wildcard TLS certificate and key     | _none_  |
| `minio.ingress.tls.secretName`          | Existing `Secret` containing TLS certificate and key for MinIO    | _none_  |
| `registry.ingress.tls.secretName`       | Existing `Secret` containing TLS certificate and key for registry | _none_  |

## Outgoing Email configuration

| Parameter                         | Description                                                                             | Default               |
|-----------------------------------|-----------------------------------------------------------------------------------------|-----------------------|
| `global.email.display_name`       | Name that appears as the sender for emails from GitLab                                  | `GitLab`              |
| `global.email.from`               | Email address that appears as the sender for emails from GitLab                         | `gitlab@example.com`  |
| `global.email.reply_to`           | Reply-to email listed in emails from GitLab                                             | `noreply@example.com` |
| `global.email.smime.certName`     | Secret object key value for locating the S/MIME certificate file                        | `tls.crt`             |
| `global.email.smime.enabled`      | Add the S/MIME signatures to outgoing email                                             | false                 |
| `global.email.smime.keyName`      | Secret object key value for locating the S/MIME key file                                | `tls.key`             |
| `global.email.smime.secretName`   | Kubernetes Secret object to find the X.509 certificate ([S/MIME Cert](secrets.md#smime-certificate) for creation ) | "" |
| `global.email.subject_suffix`     | Suffix on the subject of all outgoing email from GitLab                                 | ""                    |
| `global.smtp.address`             | Hostname or IP of the remote mail server                                                | `smtp.mailgun.org`    |
| `global.smtp.authentication`      | Type of SMTP authentication ("plain", "login", "cram_md5", or "" for no authentication) | `plain`               |
| `global.smtp.domain`              | Optional HELO domain for SMTP                                                           | ""                    |
| `global.smtp.enabled`             | Enable outgoing email                                                                   | false                 |
| `global.smtp.openssl_verify_mode` | TLS verification mode ("none", "peer", "client_once", or "fail_if_no_peer_cert")        | `peer`                |
| `global.smtp.password.key`        | Key in `global.smtp.password.secret` that contains the SMTP password                    | `password`            |
| `global.smtp.password.secret`     | Name of a `Secret` containing the SMTP password                                         | ""                    |
| `global.smtp.port`                | Port for SMTP                                                                           | `2525`                |
| `global.smtp.starttls_auto`       | Use STARTTLS if enabled on the mail server                                              | false                 |
| `global.smtp.tls`                 | Enables SMTP/TLS (SMTPS: SMTP over direct TLS connection)                               | _none_                |
| `global.smtp.user_name`           | Username for SMTP authentication https                                                  | ""                    |
| `global.smtp.pool`                | Enables SMTP connection pooling                                                         | false                 |

## Incoming Email configuration

### Common settings

| Parameter                                         | Description                                                                                            | Default                                                    |
|---------------------------------------------------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------|
| `global.appConfig.incomingEmail.address`          | The email address to reference the item being replied to (example: `gitlab-incoming+%{key}@gmail.com`) | empty                                                      |
| `global.appConfig.incomingEmail.enabled`          | Enable incoming email                                                                                  | false                                                      |
| `global.appConfig.incomingEmail.expungeDeleted`   | Whether to expunge (permanently remove) messages from the mailbox when they are deleted after delivery | false                                                      |
| `global.appConfig.incomingEmail.logger.logPath`   | Path to write JSON structured logs to; set to "" to disable this logging                               | `/dev/stdout`                                              |
| `global.appConfig.incomingEmail.inboxMethod`      | Read mail with IMAP (`imap`) or Microsoft Graph API with OAuth2 (`microsoft_graph`)                    | `imap`                                                     |
| `global.appConfig.incomingEmail.deliveryMethod`   | How mailroom can send an email content to Rails app for processing. Either `sidekiq` or `webhook`      | `sidekiq`                                                  |
| `gitlab.appConfig.incomingEmail.authToken.key`    | Key to incoming email token in incoming email secret. Effective when the delivery method is webhook.   | `authToken`                                                |
| `gitlab.appConfig.incomingEmail.authToken.secret` | Incoming email authentication secret. Effective when the delivery method is webhook.                   | `{Release.Name}-incoming-email-auth-token`                 |

### IMAP settings

| Parameter                                                     | Description                                                                                            | Default    |
|---------------------------------------------------------------|--------------------------------------------------------------------------------------------------------|------------|
| `global.appConfig.incomingEmail.host`                         | Host for IMAP                                                                                          | empty      |
| `global.appConfig.incomingEmail.idleTimeout`                  | The IDLE command timeout                                                                               | `60`       |
| `global.appConfig.incomingEmail.mailbox`                      | Mailbox where incoming mail will end up.                                                               | `inbox`    |
| `global.appConfig.incomingEmail.password.key`                 | Key in `global.appConfig.incomingEmail.password.secret` that contains the IMAP password                | `password` |
| `global.appConfig.incomingEmail.password.secret`              | Name of a `Secret` containing the IMAP password                                                        | empty      |
| `global.appConfig.incomingEmail.port`                         | Port for IMAP                                                                                          | `993`      |
| `global.appConfig.incomingEmail.ssl`                          | Whether IMAP server uses SSL                                                                           | true       |
| `global.appConfig.incomingEmail.startTls`                     | Whether IMAP server uses StartTLS                                                                      | false      |
| `global.appConfig.incomingEmail.user`                         | Username for IMAP authentication                                                                       | empty      |

### Microsoft Graph settings

| Parameter                                            | Description                                                                                              | Default    |
|------------------------------------------------------|----------------------------------------------------------------------------------------------------------|------------|
| `global.appConfig.incomingEmail.tenantId`            | The tenant ID for your Microsoft Azure Active Directory                                                  | empty      |
| `global.appConfig.incomingEmail.clientId`            | The client ID for your OAuth2 app                                                                        | empty      |
| `global.appConfig.incomingEmail.clientSecret.key`    | Key in `appConfig.incomingEmail.clientSecret.secret` that contains the OAuth2 client secret              | empty      |
| `global.appConfig.incomingEmail.clientSecret.secret` | Name of a `Secret` containing the OAuth2 client secret                                                   | secret     |
| `global.appConfig.incomingEmail.pollInterval`        | The interval in seconds how often to poll for new mail                                                   | 60         |

See the [instructions for creating secrets](secrets.md).

## Service Desk Email configuration

As a requirement for Service Desk, the Incoming Mail must be [configured](#incoming-email-configuration).
Note that the email address for both Incoming Mail and Service Desk must use
[email sub-addressing](https://docs.gitlab.com/ee/administration/incoming_email.html#email-sub-addressing).
When setting the email addresses in each section the tag added to the username
must be `+%{key}`.

### Common settings

| Parameter                                            | Description                                                                                                  | Default                                                        |
|------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------|
| `global.appConfig.serviceDeskEmail.address`          | The email address to reference the item being replied to (example: `project_contact+%{key}@gmail.com`)       | empty                                                          |
| `global.appConfig.serviceDeskEmail.enabled`          | Enable service desk email                                                                                    | false                                                          |
| `global.appConfig.serviceDeskEmail.expungeDeleted`   | Whether to expunge (permanently remove) messages from the mailbox when they are deleted after delivery       | false                                                          |
| `global.appConfig.serviceDeskEmail.logger.logPath`   | Path to write JSON structured logs to; set to "" to disable this logging                                     | `/dev/stdout`                                                  |
| `global.appConfig.serviceDeskEmail.inboxMethod`      | Read mail with IMAP (`imap`) or Microsoft Graph API with OAuth2 (`microsoft_graph`)                          | `imap`                                                         |
| `global.appConfig.serviceDeskEmail.deliveryMethod`   | How mailroom can send an email content to Rails app for processing. Either `sidekiq` or `webhook`            | `sidekiq`                                                      |
| `gitlab.appConfig.serviceDeskEmail.authToken.key`    | Key to service desk email token in service desk email secret. Effective when the delivery method is webhook. | `authToken`                                                    |
| `gitlab.appConfig.serviceDeskEmail.authToken.secret` | service-desk email authentication secret. Effective when the delivery method is webhook.                     | `{Release.Name}-service-desk-email-auth-token`                 |

### IMAP settings

| Parameter                                           | Description                                                                                            | Default       |
|-----------------------------------------------------|--------------------------------------------------------------------------------------------------------|---------------|
| `global.appConfig.serviceDeskEmail.host`            | Host for IMAP                                                                                          | empty      |
| `global.appConfig.serviceDeskEmail.idleTimeout`     | The IDLE command timeout                                                                               | `60`       |
| `global.appConfig.serviceDeskEmail.mailbox`         | Mailbox where service desk mail will end up.                                                           | `inbox`    |
| `global.appConfig.serviceDeskEmail.password.key`    | Key in `global.appConfig.serviceDeskEmail.password.secret` that contains the IMAP password             | `password` |
| `global.appConfig.serviceDeskEmail.password.secret` | Name of a `Secret` containing the IMAP password                                                        | empty      |
| `global.appConfig.serviceDeskEmail.port`            | Port for IMAP                                                                                          | `993`      |
| `global.appConfig.serviceDeskEmail.ssl`             | Whether IMAP server uses SSL                                                                           | true       |
| `global.appConfig.serviceDeskEmail.startTls`        | Whether IMAP server uses StartTLS                                                                      | false      |
| `global.appConfig.serviceDeskEmail.user`            | Username for IMAP authentication                                                                       | empty      |

### Microsoft Graph settings

| Parameter                                               | Description                                                                                                 | Default    |
|---------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|------------|
| `global.appConfig.serviceDeskEmail.tenantId`            | The tenant ID for your Microsoft Azure Active Directory                                                     | empty      |
| `global.appConfig.serviceDeskEmail.clientId`            | The client ID for your OAuth2 app                                                                           | empty      |
| `global.appConfig.serviceDeskEmail.clientSecret.key`    | Key in `appConfig.serviceDeskEmail.clientSecret.secret` that contains the OAuth2 client secret              | empty      |
| `global.appConfig.serviceDeskEmail.clientSecret.secret` | Name of a `Secret` containing the OAuth2 client secret                                                      | secret     |
| `global.appConfig.serviceDeskEmail.pollInterval`        | The interval in seconds how often to poll for new mail                                                      | 60         |

See the [instructions for creating secrets](secrets.md).

## Default Project Features configuration

| Parameter                                                    | Description                                | Default |
|--------------------------------------------------------------|--------------------------------------------|---------|
| `global.appConfig.defaultProjectsFeatures.builds`            | Enable project builds                      | true    |
| `global.appConfig.defaultProjectsFeatures.containerRegistry` | Enable container registry project features | true    |
| `global.appConfig.defaultProjectsFeatures.issues`            | Enable project issues                      | true    |
| `global.appConfig.defaultProjectsFeatures.mergeRequests`     | Enable project merge requests              | true    |
| `global.appConfig.defaultProjectsFeatures.snippets`          | Enable project snippets                    | true    |
| `global.appConfig.defaultProjectsFeatures.wiki`              | Enable project wikis                       | true    |

## GitLab Shell

| Parameter                        | Description                              | Default |
|----------------------------------|------------------------------------------|---------|
| `global.shell.authToken`         | Secret containing shared secret          |         |
| `global.shell.hostKeys`          | Secret containing SSH host keys          |         |
| `global.shell.port`              | Port number to expose on Ingress for SSH |         |
| `global.shell.tcp.proxyProtocol` | Enable ProxyProtocol in SSH Ingress      | false   |

## RBAC Settings

| Parameter                              | Description                           | Default |
|----------------------------------------|---------------------------------------|---------|
| `certmanager.rbac.create`              | Create and use RBAC resources         | true    |
| `gitlab-runner.rbac.create`            | Create and use RBAC resources         | true    |
| `nginx-ingress.rbac.create`            | Create and use default RBAC resources | false   |
| `nginx-ingress.rbac.createClusterRole` | Create and use Cluster role           | false   |
| `nginx-ingress.rbac.createRole`        | Create and use namespaced role        | true    |
| `prometheus.rbac.create`               | Create and use RBAC resources         | true    |

## Advanced NGINX Ingress configuration

Prefix NGINX Ingress values with `nginx-ingress`. For example, set the controller image tag using `nginx-ingress.controller.image.tag`.

See [`nginx-ingress` chart](../charts/nginx/index.md).

## Advanced in-cluster Redis configuration

| Parameter                            | Description                                 | Default               |
|--------------------------------------|---------------------------------------------|-----------------------|
| `redis.install`                      | Install the `bitnami/redis` chart           | true                  |
| `redis.existingSecret`               | Specify the Secret for Redis servers to use | `gitlab-redis-secret` |
| `redis.existingSecretKey`            | Secret key where password is stored         | `redis-password`      |

Any additional configuration of the Redis service should use the configuration
settings from the [Redis chart](https://github.com/bitnami/charts/tree/master/bitnami/redis).

## Advanced registry configuration

| Parameter                                           | Description                                              | Default                           |
|-----------------------------------------------------|----------------------------------------------------------|-----------------------------------|
| `registry.authEndpoint`                             | Auth endpoint                                            | Undefined by default              |
| `registry.enabled`                                  | Enable Docker registry                                   | true                              |
| `registry.httpSecret`                               | Https secret                                             |                                   |
| `registry.minio.bucket`                             | MinIO registry bucket name                               | `registry`                        |
| `registry.service.annotations`                      | Annotations to add to the `Service`                      | {}                                |
| `registry.securityContext.fsGroup`                  | Group ID under which the pod should be started           | `1000`                            |
| `registry.securityContext.runAsUser`                | User ID under which the pod should be started            | `1000`                            |
| `registry.tokenIssuer`                              | JWT token issuer                                         | `gitlab-issuer`                   |
| `registry.tokenService`                             | JWT token service                                        | `container_registry`              |
| `registry.profiling.stackdriver.enabled`            | Enable continuous profiling using Stackdriver            | `false`                           |
| `registry.profiling.stackdriver.credentials.secret` | Name of the secret containing credentials                | `gitlab-registry-profiling-creds` |
| `registry.profiling.stackdriver.credentials.key`    | Secret key in which the credentials are stored           | `credentials`                     |
| `registry.profiling.stackdriver.service`            | Name of the Stackdriver service to record profiles under | `RELEASE-registry` (templated Service name) |
| `registry.profiling.stackdriver.projectid`          | GCP project to report profiles to                        | GCP project where running         |

## Advanced MinIO configuration

| Parameter                            | Description                             | Default                        |
|--------------------------------------|-----------------------------------------|--------------------------------|
| `minio.defaultBuckets`               | MinIO default buckets                   | `[{"name": "registry"}]`       |
| `minio.image`                        | MinIO image                             | `minio/minio`                  |
| `minio.imagePullPolicy`              | MinIO image pull policy                 |                                |
| `minio.imageTag`                     | MinIO image tag                         | `RELEASE.2017-12-28T01-21-00Z` |
| `minio.minioConfig.browser`          | MinIO browser flag                      | `on`                           |
| `minio.minioConfig.domain`           | MinIO domain                            |                                |
| `minio.minioConfig.region`           | MinIO region                            | `us-east-1`                    |
| `minio.mountPath`                    | MinIO configuration file mount path     | `/export`                      |
| `minio.persistence.accessMode`       | MinIO persistence access mode           | `ReadWriteOnce`                |
| `minio.persistence.enabled`          | MinIO enable persistence flag           | true                           |
| `minio.persistence.matchExpressions` | MinIO label-expression matches to bind  |                                |
| `minio.persistence.matchLabels`      | MinIO label-value matches to bind       |                                |
| `minio.persistence.size`             | MinIO persistence volume size           | `10Gi`                         |
| `minio.persistence.storageClass`     | MinIO storageClassName for provisioning |                                |
| `minio.persistence.subPath`          | MinIO persistence volume mount path     |                                |
| `minio.persistence.volumeName`       | MinIO existing persistent volume name   |                                |
| `minio.replicas`                     | MinIO number of replicas                | `4`                            |
| `minio.resources.requests.cpu`       | MinIO minimum CPU requested             | `250m`                         |
| `minio.resources.requests.memory`    | MinIO minimum memory requested          | `256Mi`                        |
| `minio.service.annotations`          | Annotations to add to the `Service`     | {}                             |
| `minio.servicePort`                  | MinIO service port                      | `9000`                         |
| `minio.serviceType`                  | MinIO service type                      | `ClusterIP`                    |

## Advanced GitLab configuration

| Parameter                                                      | Description                                                          | Default                                                          |
|----------------------------------------------------------------|----------------------------------------------------------------------|------------------------------------------------------------------|
| `gitlab-runner.checkInterval`                                  | polling interval                                                     | `30s`                                                            |
| `gitlab-runner.concurrent`                                     | number of concurrent jobs                                            | `20`                                                             |
| `gitlab-runner.imagePullPolicy`                                | image pull policy                                                    | `IfNotPresent`                                                   |
| `gitlab-runner.image`                                          | runner image                                                         | `gitlab/gitlab-runner:alpine-v10.5.0`                            |
| `gitlab-runner.gitlabUrl`                                      | URL that the Runner uses to register to GitLab Server                                         |
GitLab external URL                                              |
| `gitlab-runner.install`                                        | install the `gitlab-runner` chart                                    | true                                                             |
| `gitlab-runner.rbac.clusterWideAccess`                         | deploy containers of jobs cluster-wide                               | false                                                            |
| `gitlab-runner.rbac.create`                                    | whether to create RBAC service account                               | true                                                             |
| `gitlab-runner.rbac.serviceAccountName`                        | name of the RBAC service account to create                           | `default`                                                        |
| `gitlab-runner.resources.limits.cpu`                           | runner resources                                                     |                                                                  |
| `gitlab-runner.resources.limits.memory`                        | runner resources                                                     |                                                                  |
| `gitlab-runner.resources.requests.cpu`                         | runner resources                                                     |                                                                  |
| `gitlab-runner.resources.requests.memory`                      | runner resources                                                     |                                                                  |
| `gitlab-runner.runners.privileged`                             | run in privileged mode,needed for `dind`                            | false                                                            |
| `gitlab-runner.runners.cache.secretName`                       | secret to get `accesskey` and `secretkey` from                       | `gitlab-minio`                                                   |
| `gitlab-runner.runners.config`                                 | Runner configuration as string                                      | See [Chart documentation](../charts/gitlab/gitlab-runner/index.md#default-runner-configuration)|
| `gitlab-runner.unregisterRunners`                              | unregister all runners before termination                            | true                                                             |
| `gitlab.geo-logcursor.securityContext.fsGroup`                 | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.geo-logcursor.securityContext.runAsUser`               | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.gitaly.authToken.key`                                  | Key to Gitaly token in the secret                                    | `token`                                                          |
| `gitlab.gitaly.authToken.secret`                               | Gitaly secret name                                                   | `{.Release.Name}-gitaly-secret`                                  |
| `gitlab.gitaly.image.pullPolicy`                               | Gitaly image pull policy                                             |                                                                  |
| `gitlab.gitaly.image.repository`                               | Gitaly image repository                                              | `registry.gitlab.com/gitlab-org/build/cng/gitaly`                |
| `gitlab.gitaly.image.tag`                                      | Gitaly image tag                                                     | `master`                                                         |
| `gitlab.gitaly.persistence.accessMode`                         | Gitaly persistence access mode                                       | `ReadWriteOnce`                                                  |
| `gitlab.gitaly.persistence.enabled`                            | Gitaly enable persistence flag                                       | true                                                             |
| `gitlab.gitaly.persistence.matchExpressions`                   | Label-expression matches to bind                                     |                                                                  |
| `gitlab.gitaly.persistence.matchLabels`                        | Label-value matches to bind                                          |                                                                  |
| `gitlab.gitaly.persistence.size`                               | Gitaly persistence volume size                                       | `50Gi`                                                           |
| `gitlab.gitaly.persistence.storageClass`                       | storageClassName for provisioning                                    |                                                                  |
| `gitlab.gitaly.persistence.subPath`                            | Gitaly persistence volume mount path                                 |                                                                  |
| `gitlab.gitaly.persistence.volumeName`                         | Existing persistent volume name                                      |                                                                  |
| `gitlab.gitaly.securityContext.fsGroup`                        | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.gitaly.securityContext.runAsUser`                      | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.gitaly.service.annotations`                            | Annotations to add to the `Service`                                  | `{}`                                                             |
| `gitlab.gitaly.service.externalPort`                           | Gitaly service exposed port                                          | `8075`                                                           |
| `gitlab.gitaly.service.internalPort`                           | Gitaly internal port                                                 | `8075`                                                           |
| `gitlab.gitaly.service.name`                                   | Gitaly service name                                                  | `gitaly`                                                         |
| `gitlab.gitaly.service.type`                                   | Gitaly service type                                                  | `ClusterIP`                                                      |
| `gitlab.gitaly.serviceName`                                    | Gitaly service name                                                  | `gitaly`                                                         |
| `gitlab.gitaly.shell.authToken.key`                            | Shell key                                                            | `secret`                                                         |
| `gitlab.gitaly.shell.authToken.secret`                         | Shell secret                                                         | `{Release.Name}-gitlab-shell-secret`                             |
| `gitlab.gitlab-exporter.securityContext.fsGroup`               | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.gitlab-exporter.securityContext.runAsUser`             | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.gitlab-shell.authToken.key`                            | Shell auth secret key                                                | `secret`                                                         |
| `gitlab.gitlab-shell.authToken.secret`                         | Shell auth secret                                                    | `{Release.Name}-gitlab-shell-secret`                             |
| `gitlab.gitlab-shell.enabled`                                  | Shell enable flag                                                    | true                                                             |
| `gitlab.gitlab-shell.image.pullPolicy`                         | Shell image pull policy                                              |                                                                  |
| `gitlab.gitlab-shell.image.repository`                         | Shell image repository                                               | `registry.gitlab.com/gitlab-org/build/cng/gitlab-shell`          |
| `gitlab.gitlab-shell.image.tag`                                | Shell image tag                                                      | `master`                                                         |
| `gitlab.gitlab-shell.replicaCount`                             | Shell replicas                                                       | `1`                                                              |
| `gitlab.gitlab-shell.securityContext.fsGroup`                  | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.gitlab-shell.securityContext.runAsUser`                | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.gitlab-shell.service.annotations`                      | Annotations to add to the `Service`                                  | {}                                                               |
| `gitlab.gitlab-shell.service.internalPort`                     | Shell internal port                                                  | `2222`                                                           |
| `gitlab.gitlab-shell.service.name`                             | Shell service name                                                   | `gitlab-shell`                                                   |
| `gitlab.gitlab-shell.service.type`                             | Shell service type                                                   | `ClusterIP`                                                      |
| `gitlab.gitlab-shell.webservice.serviceName`                   | Webservice service name                                              | inherited from `global.webservice.serviceName`                                    |
| `gitlab.mailroom.securityContext.fsGroup`                      | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.mailroom.securityContext.runAsUser`                    | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.migrations.bootsnap.enabled`                           | Migrations Bootsnap enable flag                                      | true                                                             |
| `gitlab.migrations.enabled`                                    | Migrations enable flag                                               | true                                                             |
| `gitlab.migrations.image.pullPolicy`                           | Migrations pull policy                                               |                                                                  |
| `gitlab.migrations.image.repository`                           | Migrations image repository                                          | `registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee`     |
| `gitlab.migrations.image.tag`                                  | Migrations image tag                                                 | `master`                                                         |
| `gitlab.migrations.psql.password.key`                          | key to psql password in psql secret                                  | `psql-password`                                                  |
| `gitlab.migrations.psql.password.secret`                       | psql secret                                                          | `gitlab-postgres`                                                |
| `gitlab.migrations.psql.port`                                  | Set PostgreSQL server port. Takes precedence over `global.psql.port` |                                                                  |
| `gitlab.migrations.securityContext.fsGroup`                    | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.migrations.securityContext.runAsUser`                  | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.sidekiq.concurrency`                                   | Sidekiq default concurrency                                          | `10`                                                             |
| `gitlab.sidekiq.enabled`                                       | Sidekiq enabled flag                                                 | true                                                             |
| `gitlab.sidekiq.gitaly.authToken.key`                          | key to Gitaly token in Gitaly secret                                 | `token`                                                          |
| `gitlab.sidekiq.gitaly.authToken.secret`                       | Gitaly secret                                                        | `{.Release.Name}-gitaly-secret`                                  |
| `gitlab.sidekiq.gitaly.serviceName`                            | Gitaly service name                                                  | `gitaly`                                                         |
| `gitlab.sidekiq.image.pullPolicy`                              | Sidekiq image pull policy                                            |                                                                  |
| `gitlab.sidekiq.image.repository`                              | Sidekiq image repository                                             | `registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ee`     |
| `gitlab.sidekiq.image.tag`                                     | Sidekiq image tag                                                    | `master`                                                         |
| `gitlab.sidekiq.psql.password.key`                             | key to psql password in psql secret                                  | `psql-password`                                                  |
| `gitlab.sidekiq.psql.password.secret`                          | psql password secret                                                 | `gitlab-postgres`                                                |
| `gitlab.sidekiq.psql.port`                                     | Set PostgreSQL server port. Takes precedence over `global.psql.port` |                                                                  |
| `gitlab.sidekiq.replicas`                                      | Sidekiq replicas                                                     | `1`                                                              |
| `gitlab.sidekiq.resources.requests.cpu`                        | Sidekiq minimum needed CPU                                           | `100m`                                                           |
| `gitlab.sidekiq.resources.requests.memory`                     | Sidekiq minimum needed memory                                        | `600M`                                                           |
| `gitlab.sidekiq.securityContext.fsGroup`                       | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.sidekiq.securityContext.runAsUser`                     | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.sidekiq.timeout`                                       | Sidekiq job timeout                                                  | `5`                                                              |
| `gitlab.toolbox.annotations`                               | Annotations to add to the toolbox                                    | {}                                                               |
| `gitlab.toolbox.backups.cron.enabled`                      | Backup CronJob enabled flag                                          | false                                                            |
| `gitlab.toolbox.backups.cron.extraArgs`                    | String of arguments to pass to the backup utility                    |                                                                  |
| `gitlab.toolbox.backups.cron.persistence.accessMode`       | Backup cron persistence access mode                                  | `ReadWriteOnce`                                                  |
| `gitlab.toolbox.backups.cron.persistence.enabled`          | Backup cron enable persistence flag                                  | false                                                            |
| `gitlab.toolbox.backups.cron.persistence.matchExpressions` | Label-expression matches to bind                                     |                                                                  |
| `gitlab.toolbox.backups.cron.persistence.matchLabels`      | Label-value matches to bind                                          |                                                                  |
| `gitlab.toolbox.backups.cron.persistence.size`             | Backup cron persistence volume size                                  | `10Gi`                                                           |
| `gitlab.toolbox.backups.cron.persistence.storageClass`     | storageClassName for provisioning                                    |                                                                  |
| `gitlab.toolbox.backups.cron.persistence.subPath`          | Backup cron persistence volume mount path                            |                                                                  |
| `gitlab.toolbox.backups.cron.persistence.volumeName`       | Existing persistent volume name                                      |                                                                  |
| `gitlab.toolbox.backups.cron.resources.requests.cpu`       | Backup cron minimum needed CPU                                       | `50m`                                                            |
| `gitlab.toolbox.backups.cron.resources.requests.memory`    | Backup cron minimum needed memory                                    | `350M`                                                           |
| `gitlab.toolbox.backups.cron.schedule`                     | Cron style schedule string                                           | `0 1 * * *`                                                      |
| `gitlab.toolbox.backups.objectStorage.backend`             | Object storage provider to use (`s3` or `gcs`)                       | `s3`                                                             |
| `gitlab.toolbox.backups.objectStorage.config.gcpProject`   | GCP Project to use when backend is `gcs`                             | ""                                                               |
| `gitlab.toolbox.backups.objectStorage.config.key`          | key containing credentials in secret                                 | ""                                                               |
| `gitlab.toolbox.backups.objectStorage.config.secret`       | Object storage credentials secret                                    | ""                                                               |
| `gitlab.toolbox.backups.objectStorage.config`              | Authentication information for object storage                        | {}                                                               |
| `gitlab.toolbox.bootsnap.enabled`                          | Enable Bootsnap cache in Toolbox                                     | true                                                             |
| `gitlab.toolbox.enabled`                                   | Toolbox enabled flag                                                 | true                                                             |
| `gitlab.toolbox.image.pullPolicy`                          | Toolbox image pull policy                                            | `IfNotPresent`                                                   |
| `gitlab.toolbox.image.repository`                          | Toolbox image repository                                             | `registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ee` |
| `gitlab.toolbox.image.tag`                                 | Toolbox image tag                                                    | `master`                                                         |
| `gitlab.toolbox.init.image.repository`                     | Toolbox init image repository                                        |                                                                  |
| `gitlab.toolbox.init.image.tag`                            | Toolbox init image tag                                               |                                                                  |
| `gitlab.toolbox.init.resources.requests.cpu`               | Toolbox init minimum needed CPU                                      | `50m`                                                            |
| `gitlab.toolbox.persistence.accessMode`                    | Toolbox persistence access mode                                      | `ReadWriteOnce`                                                  |
| `gitlab.toolbox.persistence.enabled`                       | Toolbox enable persistence flag                                      | false                                                            |
| `gitlab.toolbox.persistence.matchExpressions`              | Label-expression matches to bind                                     |                                                                  |
| `gitlab.toolbox.persistence.matchLabels`                   | Label-value matches to bind                                          |                                                                  |
| `gitlab.toolbox.persistence.size`                          | Toolbox persistence volume size                                      | `10Gi`                                                           |
| `gitlab.toolbox.persistence.storageClass`                  | storageClassName for provisioning                                    |                                                                  |
| `gitlab.toolbox.persistence.subPath`                       | Toolbox persistence volume mount path                                |                                                                  |
| `gitlab.toolbox.persistence.volumeName`                    | Existing persistent volume name                                      |                                                                  |
| `gitlab.toolbox.psql.port`                                 | Set PostgreSQL server port. Takes precedence over `global.psql.port` |                                                                  |
| `gitlab.toolbox.resources.requests.cpu`                    | Toolbox minimum needed CPU                                           | `50m`                                                            |
| `gitlab.toolbox.resources.requests.memory`                 | Toolbox minimum needed memory                                        | `350M`                                                           |
| `gitlab.toolbox.securityContext.fsGroup`                   | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.toolbox.securityContext.runAsUser`                 | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.webservice.enabled`                                    | webservice enabled flag                                              | true                                                             |
| `gitlab.webservice.gitaly.authToken.key`                       | Key to Gitaly token in Gitaly secret                                 | `token`                                                          |
| `gitlab.webservice.gitaly.authToken.secret`                    | Gitaly secret name                                                   | `{.Release.Name}-gitaly-secret`                                  |
| `gitlab.webservice.gitaly.serviceName`                         | Gitaly service name                                                  | `gitaly`                                                         |
| `gitlab.webservice.image.pullPolicy`                           | webservice image pull policy                                         |                                                                  |
| `gitlab.webservice.image.repository`                           | webservice image repository                                          | `registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ee`  |
| `gitlab.webservice.image.tag`                                  | webservice image tag                                                 | `master`                                                         |
| `gitlab.webservice.psql.password.key`                          | Key to psql password in psql secret                                  | `psql-password`                                                  |
| `gitlab.webservice.psql.password.secret`                       | psql secret name                                                     | `gitlab-postgres`                                                |
| `gitlab.webservice.psql.port`                                  | Set PostgreSQL server port. Takes precedence over `global.psql.port` |                                                                  |
| `gitlab.webservice.registry.api.port`                          | Registry port                                                        | `5000`                                                           |
| `gitlab.webservice.registry.api.protocol`                      | Registry protocol                                                    | `http`                                                           |
| `gitlab.webservice.registry.api.serviceName`                   | Registry service name                                                | `registry`                                                       |
| `gitlab.webservice.registry.tokenIssuer`                       | Registry token issuer                                                | `gitlab-issuer`                                                  |
| `gitlab.webservice.replicaCount`                               | webservice number of replicas                                        | `1`                                                              |
| `gitlab.webservice.resources.requests.cpu`                     | webservice minimum CPU                                               | `200m`                                                           |
| `gitlab.webservice.resources.requests.memory`                  | webservice minimum memory                                            | `1.4G`                                                           |
| `gitlab.webservice.securityContext.fsGroup`                    | Group ID under which the pod should be started                       | `1000`                                                           |
| `gitlab.webservice.securityContext.runAsUser`                  | User ID under which the pod should be started                        | `1000`                                                           |
| `gitlab.webservice.service.annotations`                        | Annotations to add to the `Service`                                  | {}                                                               |
| `gitlab.webservice.service.externalPort`                       | webservice exposed port                                              | `8080`                                                           |
| `gitlab.webservice.service.internalPort`                       | webservice internal port                                             | `8080`                                                           |
| `gitlab.webservice.service.type`                               | webservice service type                                              | `ClusterIP`                                                      |
| `gitlab.webservice.service.workhorseExternalPort`              | Workhorse exposed port                                               | `8181`                                                           |
| `gitlab.webservice.service.workhorseInternalPort`              | Workhorse internal port                                              | `8181`                                                           |
| `gitlab.webservice.shell.authToken.key`                        | Key to shell token in shell secret                                   | `secret`                                                         |
| `gitlab.webservice.shell.authToken.secret`                     | Shell token secret                                                   | `{Release.Name}-gitlab-shell-secret`                             |
| `gitlab.webservice.workerProcesses`                            | webservice number of workers                                         | `2`                                                              |
| `gitlab.webservice.workerTimeout`                              | webservice worker timeout                                            | `60`                                                             |
| `gitlab.webservice.workhorse.extraArgs`                        | String of extra parameters for workhorse                             | ""                                                               |
| `gitlab.webservice.workhorse.image`                            | Workhorse image repository                                           | `registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ee`   |
| `gitlab.webservice.workhorse.sentryDSN`                        | DSN for Sentry instance for error reporting                          | ""                                                               |
| `gitlab.webservice.workhorse.tag`                              | Workhorse image tag                                                  |                                                                  |

## External Charts

GitLab makes use of several other charts. These are [treated as parent-child relationships](https://helm.sh/docs/topics/charts/#chart-dependencies).
Ensure that any properties you wish to configure are provided as `chart-name.property`.

## Prometheus

Prefix Prometheus values with `prometheus`. For example, set the persistence
storage value using `prometheus.server.persistentVolume.size`.

Refer to the [Prometheus chart documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus)
for the exhaustive list of configuration options.

## Bringing your own images

In certain scenarios (i.e. air-gapping), you may want to bring your own images rather than pulling them down from the Internet. This requires specifying your own Docker image registry/repository for each of the charts that make up the GitLab release.

Refer to the [custom images documentation](../advanced/custom-images/index.md) for more information.
