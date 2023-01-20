---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Goals

We have a few core goals with this initiative:

1. Easy to scale horizontally
1. Easy to deploy, upgrade, maintain
1. Wide support of cloud service providers
1. Initial support for Kubernetes and Helm, with flexibility to support other
   schedulers in the future

## Scheduler

We will launch with support for Kubernetes, which is mature and widely supported
across the industry. As part of our design however, we will try to avoid decisions
which will preclude the support of other schedulers. This is especially true for
downstream Kubernetes projects like OpenShift and Tectonic. In the future other
schedulers may also be supported like Docker Swarm and Mesosphere.

We aim to support the scaling and self-healing capabilities of Kubernetes:

- Readiness and Health checks to ensure pods are functioning, and if not to recycle them
- Tracks to support canary and rolling deployments
- [Auto-scaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)

We will try to leverage standard Kubernetes features:

- ConfigMaps for managing configuration. These will then get mapped or passed to
  Docker containers
- Secrets for sensitive data

Since we might be also using Consul, this may be utilized instead for consistency with other installation methods.

## Helm Charts

A Helm chart will be created to manage the deployment of each GitLab specific container/service. We will then also include bundled charts to make the overall deployment easier. This is particularly
important for this effort, as there will be significantly more complexity in
the Docker and Kubernetes layers than the all-in-one Omnibus based solutions.
Helm can help to manage this complexity, and provide an easy top level interface
to manage settings via the `values.yaml` file.

We plan to offer a three tiered set of Helm Charts

![Helm Chart Structure](../images/charts.png)
