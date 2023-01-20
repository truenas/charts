---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Environment setup

To set up for charts development, command line tools and a
Kubernetes cluster are required.

## Required developer tools

The minimum tools required for charts development are documented on the [Required tools page](../installation/tools.md).

We recommend using [`asdf`](https://github.com/asdf-vm/asdf) to install these tools.
This allows us to easily switch between versions, Helm 3.4 and 3.5 for example.

### Additional developer tools

Developers working on charts also often use the following tools:

Tool name | Benefits | Example use case | Link(s)
-|-|-|-
`asdf` | Easily switch between versions of your favorite runtimes and CLI tools. | Switching between Helm 3.4 and Helm 3.5 binaries. | [GitHub](https://github.com/asdf-vm/asdf)
`kubectx` & `kubens` | Manage and switch between Kubernetes contexts and namespaces. | Setting default namespace per selected cluster context. | [GitHub](https://github.com/ahmetb/kubectx)
`k3s` | Lightweight Kubernetes installation (<40MB). | Quick and reliable local chart testing. | [Homepage](https://k3s.io)
`k9s` | Greatly reduced typing of `kubectl` commands. | Navigate and manage cluster resources quickly in a command line interface. | [GitHub](https://github.com/derailed/k9s)
`lens` | Highly visual management and navigation of clusters. | Navigate and manage cluster resources quickly in a standalone desktop application. | [Homepage](https://k8slens.dev/)
`stern` | Easily follow logs from multiple pods. | See logs from a set of GitLab pods together. | [GitHub](https://github.com/wercker/stern)
`dive` | Explore container layers. | A tool for exploring a container image, layer contents, and discovering ways to shrink the size of your Docker/OCI image. | [GitHub](https://github.com/wagoodman/dive), [GitLab Unfiltered](https://youtu.be/9kdE-ye6vlc)

## Kubernetes cluster

A cloud or local Kubernetes cluster may be used for development.
For simple issues, a local cluster will often be enough to test deployments.
When dealing with networking, storage, or other complex issues, a cloud Kubernetes cluster will allow you to more accurately recreate a production environment.

### Local cluster

The following local cluster options are supported:

- [minikube](minikube/index.md) - Cluster in virtual machines
- [KinD (Kubernetes in Docker)](kind/index.md) - Cluster in Docker containers

### Cloud cluster

The following cloud cluster options are supported:

- [GKE](../installation/cloud/gke.md) - Google Kubernetes Engine, recommended
- [EKS](../installation/cloud/eks.md) - Amazon Elastic Kubernetes Service

## Installing from repository

Details on installing the chart from the Git repository can be found in the [developer deployment](deploy.md) documentation.
