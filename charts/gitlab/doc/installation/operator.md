---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# GitLab Operator **(FREE SELF)**

NOTE:
The [GitLab Operator](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator) is under active development and is not yet suitable for production use. See our [`Minimal` to `Viable` Epic](https://gitlab.com/groups/gitlab-org/cloud-native/-/epics/39) for more information.

NOTE:
If you want to integrate GitLab with OpenShift, see the [OpenShift and GitLab documentation](https://docs.gitlab.com/ee/install/openshift_and_gitlab/index.html).

GitLab Operator is an implementation of the [Operator pattern](https://docs.openshift.com/container-platform/latest/operators/understanding/olm-what-operators-are.html)
for managing the lifecycle and upgrades of a GitLab instance. The GitLab Operator strengthens the support of OpenShift from GitLab, but is intended to be as native to Kubernetes as for OpenShift. The GitLab Operator provides a method of synchronizing and controlling various
stages of cloud-native GitLab installation and upgrade procedures. Using the Operator provides the ability to perform
rolling upgrades with minimal down time. The first goal is to support OpenShift, the subsequent goal will be for automation of day 2 operations like upgrades as noted.

The Operator offers the benefit of Day 2 operators to the GitLab installation, there are many automation benefits to utilizing the Operator vs Helm. The Operator utilizes the Helm Chart but the Operator will continuously run making upgrading, backups, and more, automatic.

The GitLab Operator aims to:

- Manage the full lifecycle of GitLab instances in your OpenShift container platforms.
- Ease the installation and configuration of GitLab instances.
- Offer seamless upgrades from version to version.
- Ease backup and restore of GitLab and its components.
- Aggregate and visualize metrics using Prometheus and Grafana.
- Set up auto-scaling.

The GitLab Operator does not include the GitLab Runner. For more information, see
the [GitLab Runner Operator repository](https://gitlab.com/gitlab-org/gl-openshift/gitlab-runner-operator).

## Known limitations

Below are the known limitations of the GitLab Operator:

- Certain components not supported:
  - Praefect: see issue [#136](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/issues/136)
  - KAS: see issue [#139](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/issues/139)

## Prerequisites

Before you install GitLab with GitLab Operator, you must:

1. Create or use an existing Kubernetes or OpenShift cluster:
   - **Kubernetes:** To create a traditional Kubernetes cluster, consider using
     the [official tooling](https://kubernetes.io/docs/tasks/tools/) or your
     preferred method of installation. The GitLab Operator supports Kubernetes
     1.19 through 1.21. Support for Kubernetes 1.22 is under active development - see
     [&6883](https://gitlab.com/groups/gitlab-org/-/epics/6883) for more information.
   - **OpenShift:** To create an OpenShift cluster, see the [OpenShift cluster setup docs](cloud/openshift.md).
     The GitLab Operator supports OpenShift 4.6 through 4.9. Support for Kubernetes 1.22
     is under active development - see [&6883](https://gitlab.com/groups/gitlab-org/-/epics/6883)
     for more information.

1. Install the following services and software:

   - **Ingress controller**

     An Ingress controller is required to provide external access to the application and secure communication between components.
     The GitLab Operator will deploy our [forked NGINX chart from the GitLab Helm Chart](../charts/nginx/index.md) by default.
     If you prefer to use an external Ingress controller, we recommend [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/deploy/) by the Kubernetes community to deploy an Ingress Controller. Follow the relevant instructions in the link based on your platform and preferred tooling. Take note of the Ingress class value for later (it typically defaults to `nginx`).

     When configuring the GitLab custom resource (CR), be sure to set `nginx-ingress.enabled=false` to disable the NGINX objects from the GitLab Helm Chart.

   - **Certificate manager**

     For the TLS certificates, we recommend [Cert Manager](https://cert-manager.io/docs/installation/)
     to create certificates used to secure the GitLab and Registry URLs. Follow
     the relevant instructions in the link based on your platform and preferred tooling.

     Our codebase currently targets Cert Manager 1.6.1.

     NOTE:
     Cert Manager [1.6](https://github.com/jetstack/cert-manager/releases/tag/v1.6.0) removed some deprecated APIs. As a result, if deploying Cert Manager >= 1.6, you will need GitLab Operator >= 0.4.

   - **Metrics server**

     - Kubernetes: Install the [metrics server](https://github.com/kubernetes-sigs/metrics-server#installation) so the HorizontalPodAutoscalers can retrieve pod metrics.
     - OpenShift: OpenShift ships with [Prometheus Adapter](https://docs.openshift.com/container-platform/4.6/monitoring/understanding-the-monitoring-stack.html#default-monitoring-components_understanding-the-monitoring-stack) by default, so there is no manual action required here.

1. Configure the Domain Name services:

   You will need an internet-accessible domain to which you can add a DNS record.
   See our [networking and DNS documentation](deployment.md#networking-and-dns)
   for more details on connecting your domain to the GitLab components. You will
   use the configuration mentioned in this section when defining your GitLab
   custom resource (CR).

## Install the GitLab Operator

This document describes how to deploy the GitLab Operator via manifests in your
Kubernetes or OpenShift cluster.

If using OpenShift, these steps normally are handled by the Operator Lifecycle
Manager (OLM) once an operator is bundle published. However, to test the most
recent operator images, users may need to install the operator using the
deployment manifests available in the
[operator repository](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/tree/master).

1. Deploy the GitLab Operator:

   ```shell
   # Use latest version of operator released at
   #  https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases
   GL_OPERATOR_VERSION=0.4.0
   PLATFORM=kubernetes # or "openshift"
   kubectl create namespace gitlab-system
   kubectl apply -f https://gitlab.com/api/v4/projects/18899486/packages/generic/gitlab-operator/${GL_OPERATOR_VERSION}/gitlab-operator-${PLATFORM}-${GL_OPERATOR_VERSION}.yaml
   ```

   NOTE:
   `18899486` is the ID of the
   [GitLab Operator project](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator).

   This command first deploys the service accounts, roles and role bindings used by the operator, and then the operator itself.

   By default, the Operator will only watch the namespace where it is deployed.
   If you'd like it to watch at the cluster scope, then remove the `WATCH_NAMESPACE`
   environment variable from the Deployment in the manifest under:
   `spec.template.spec.containers[0].env` and re-run the `kubectl apply` command above.

   NOTE:
   Running the Operator at the cluster scope is considered experimental.
   See [issue #100](https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/issues/100) for more information.

1. Create a GitLab custom resource (CR), by creating a new YAML file (for example
   named `mygitlab.yaml`). Here is an example of the content to put in
   this file:

   ```yaml
   apiVersion: apps.gitlab.com/v1beta1
   kind: GitLab
   metadata:
     name: example
   spec:
     chart:
       # Provided <Operator Version> is the released version from 
       #  https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases
       # obtain list of available chart versions from:
       #  https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/blob/<Operator Version>/CHART_VERSIONS
       version: "X.Y.Z" 
       values:
         global:
           hosts:
             domain: example.com # Provide a real base domain for GitLab. "gitlab." and "registry." will be exposed as subdomains.
             externalIP: "1.1.1.1" # If using a static wildcard DNS record for the base domain, enter the IP address it resolves to here.
           ingress:
             configureCertmanager: true
         certmanager-issuer:
           email: youremail@example.com # use your real email address here
   ```

   For more details on configuration options to use under `spec.chart.values`,
   see the [GitLab Helm Chart documentation](../charts/index.md).

1. Deploy a GitLab instance using your new GitLab CR:

   ```shell
   kubectl -n gitlab-system apply -f mygitlab.yaml
   ```

   This command sends your GitLab CR up to the cluster for the GitLab Operator
   to reconcile. You can watch the progress by tailing the logs from the controller pod:

   ```shell
   kubectl -n gitlab-system logs deployment/gitlab-controller-manager -c manager -f
   ```

   You can also list GitLab resources and check their status:

   ```shell
   kubectl get gitlabs -n gitlab-system
   ```

   When the CR is reconciled (the status of the GitLab resource will be `RUNNING`),
   you can access GitLab in your browser at the domain you set up in the custom
   resource.

   To log in use the base domain you specified, with the `gitlab` subdomain, for example: `https://gitlab.example.com`. An initial administrator account has also been created. The username is `root` and the password is stored in the `<name>-gitlab-initial-root-password` secret. By default, this is in the `gitlab-system` namespace, and must be base64 decoded to use.

  ```shell
  kubectl -n gitlab-system get secret <name>-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo
  ```

## Uninstall the GitLab Operator

Items to note prior to uninstalling the Operator:

- The operator does not delete the Persistent Volume Claims or Secrets when a
  GitLab instance is deleted.
- When deleting the Operator, the namespace where it's installed
  (`gitlab-system` by default) will not be deleted automatically. This is to
  ensure persistent volumes are not lost unintentionally.

To remove the GitLab Operator and its associated resources:

1. Uninstall the GitLab instance:

   ```shell
   kubectl -n gitlab-system delete -f mygitlab.yaml
   ```

   This will remove the GitLab instance, and all associated objects except for
   PVCs as noted above.

1. Uninstall the GitLab Operator.

   ```shell
   # Use latest version of operator released at
   #  https://gitlab.com/gitlab-org/cloud-native/gitlab-operator/-/releases
   GL_OPERATOR_VERSION=0.4.0
   PLATFORM=kubernetes # or "openshift"
   kubectl delete -f https://gitlab.com/api/v4/projects/18899486/packages/generic/gitlab-operator/${GL_OPERATOR_VERSION}/gitlab-operator-${PLATFORM}-${GL_OPERATOR_VERSION}.yaml
   ```

   This will delete the Operator's resources, including the running Deployment
   of the Operator. This **will not** delete objects associated with a GitLab instance.
