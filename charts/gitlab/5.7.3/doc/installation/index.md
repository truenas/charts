---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Installing GitLab using Helm **(FREE SELF)**

Install GitLab on Kubernetes with the cloud native GitLab Helm chart.

## Requirements

To deploy GitLab on Kubernetes, the following are required:

1. kubectl `1.16` or higher, compatible with your cluster
   ([+/- 1 minor release from your cluster](https://kubernetes.io/docs/tasks/tools/)).
1. Helm v3 (3.3.1 or higher).
1. A Kubernetes cluster, version 1.16 through 1.21. 8vCPU and 30GB of RAM is recommended.

    - Please refer to our [Cloud Native Hybrid reference architectures](https://docs.gitlab.com/ee/administration/reference_architectures/#available-reference-architectures) for the cluster topology recommendations for the specific environment sizes.

NOTE:
If using the in-chart NGINX Ingress Controller (`nginx-ingress.enabled=true`),
then Kubernetes 1.19 or newer is required.

NOTE:
Support for Kubernetes 1.22 is under active development - see
[&6883](https://gitlab.com/groups/gitlab-org/-/epics/6883) for more information.

NOTE:
Helm v2 has reached end of lifecyle. If GitLab has been previously installed
with Helm v2, you should use Helm v3 as soon as possible. Please consult
the [Helm migration document](migration/helm.md).

## Environment setup

Before proceeding to deploying GitLab, you need to prepare your environment.

### Tools

`helm` and `kubectl` need to be [installed on your computer](tools.md).

### Cloud cluster preparation

NOTE:
[Kubernetes 1.16 through 1.21 is required](#requirements), due to the usage of certain
Kubernetes features.

Follow the instructions to create and connect to the Kubernetes cluster of your
choice:

- [Amazon EKS](cloud/eks.md)
- [Azure Kubernetes Service](cloud/aks.md)
- [Google Kubernetes Engine](cloud/gke.md)
- [OpenShift](cloud/openshift.md)
- [Oracle Container Engine for Kubernetes](cloud/oke.md)
- VMware Tanzu - Documentation to be added.
- On-Premises solutions - Documentation to be added.

## Deploying GitLab

With the environment set up and configuration generated, you can now proceed to
the [deployment of GitLab](deployment.md).

## Upgrading GitLab

If you are upgrading an existing Kubernetes installation, follow the
[upgrade documentation](upgrade.md) instead.

## Migrate from or to the GitLab Helm chart

To migrate your existing GitLab Linux package installation to your Kubernetes cluster,
or vice versa, follow the [migration documentation](migration/index.md).
