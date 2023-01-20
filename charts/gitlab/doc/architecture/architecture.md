---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Architecture

We plan to support three tiers of components:

1. Docker Containers
1. Scheduler (Kubernetes)
1. Higher level configuration tool (Helm)

The main method customers would use to install would be the [Helm Chart](https://helm.sh/) in this repository.
At some point in the future, we may also offer other deployment methods like
Amazon CloudFormation or Docker Swarm.

## Docker Container Images

As a foundation, we will be creating a Docker container for each service.
This will allow easier horizontal scaling with reduced image size and complexity.
Configuration should be passed in a standard way for Docker, perhaps environment
variables or a mounted file. This provides a clean common interface with the
scheduler software.

### GitLab Docker Images

The GitLab application is built using Docker images that contain GitLab
specific services. The build environments for these images can be found in
the [CNG repository](https://gitlab.com/gitlab-org/build/CNG).

The following GitLab components have images in the CNG repository.

- Gitaly
- GitLab Elasticsearch Indexer
- [mail_room](https://github.com/tpitale/mail_room)
- GitLab Exporter
- GitLab Shell
- Sidekiq
- GitLab Toolbox
- Webservice
- Workhorse

The following are forked charts which also use GitLab specific Docker images.

Docker images that are used for `initContainers` and various `Job`s.

- alpine-certificates
- kubectl

### Official Docker Images

We leverage the following existing official containers for
underlying services:

- Docker Distribution ([Docker Registry 2.0](https://github.com/docker/distribution))
- Prometheus
- NGINX Ingress
- cert-manager
- Redis
- PostgreSQL
- Grafana

## The GitLab Chart

This is the top level `gitlab` chart, which configures all necessary resources
for a complete configuration of GitLab. This includes GitLab, PostgreSQL, Redis,
Ingress, and certificate management charts.

At this high level, a customer can make decisions like:

- Whether they want to use the embedded PostgreSQL chart, or to use an external
  database like Amazon RDS for PostgreSQL.
- To bring their own SSL certificates, or leverage Let's Encrypt.
- To use a load balancer, or a dedicated Ingress.

Customers who would like to get started quickly and easily should begin with this chart.

### Structure of these charts

The main GitLab chart is an umbrella chart, made up of many other charts. Each sub-chart is
documented individually, and laid in a structure that matches the
[charts](https://gitlab.com/gitlab-org/charts/gitlab/tree/master/charts) directory structure.

Non-GitLab components are packaged and documented on the top level. GitLab
component services are documented under the [GitLab](../charts/gitlab/index.md) chart:

- [NGINX](../charts/nginx/index.md)
- [MinIO](../charts/minio/index.md)
- [Registry](../charts/registry/index.md)
- GitLab/[Gitaly](../charts/gitlab/gitaly/index.md)
- GitLab/[GitLab Exporter](../charts/gitlab/gitlab-exporter/index.md)
- GitLab/[GitLab Grafana](../charts/gitlab/gitlab-grafana/index.md)
- GitLab/[GitLab Shell](../charts/gitlab/gitlab-shell/index.md)
- GitLab/[Migrations](../charts/gitlab/migrations/index.md)
- GitLab/[Sidekiq](../charts/gitlab/sidekiq/index.md)
- GitLab/[Webservice](../charts/gitlab/webservice/index.md)

### Components list

A list of which components are deployed when using the chart, and configuration instructions if needed,
is available on the [architecture components list](https://docs.gitlab.com/ee/development/architecture.html#component-list) page.

## Design Decisions

Documentation of the decisions made regarding the architecture of these charts can
be found in [Design Decisions](decisions.md) documentation
