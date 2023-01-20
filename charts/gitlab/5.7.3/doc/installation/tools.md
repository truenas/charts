---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Required tools **(FREE SELF)**

Before deploying GitLab to your Kubernetes cluster, there are some tools you
must have installed locally.

## kubectl

kubectl is the tool that talks to the Kubernetes API. kubectl 1.16 or higher is
required and it needs to be compatible with your cluster
([+/- 1 minor release from your cluster](https://kubernetes.io/docs/tasks/tools/)).

[> Install kubectl locally by following the Kubernetes documentation.](https://kubernetes.io/docs/tasks/tools/)

### Connecting to a Kubernetes cluster

Ensure that you are able to connect to a Kubernetes cluster by running
`kubectl version` and confirming that both Client and Server versions are returned.
Below are instructions for connecting kubectl to common Kubernetes platforms.

#### GKE

The command to connect to the cluster can be obtained from the
[Google Cloud Platform Console](https://console.cloud.google.com/kubernetes/list)
by the individual cluster, by looking for the **Connect** button in the clusters
list page.

Alternatively, use the command below, filling in your cluster's information:

```shell
gcloud container clusters get-credentials <cluster-name> --zone <zone> --project <project-id>
```

#### EKS

For the most up to date instructions, follow the Amazon EKS documentation on
[connecting to a cluster](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html#eks-configure-kubectl).

#### minikube

If you are doing local development, you can use `minikube` as your
local cluster. If `kubectl cluster-info` is not showing `minikube` as the current
cluster, use `kubectl config set-cluster minikube` to set the active cluster.

## Helm

Helm is the package manager for Kubernetes. The `gitlab` chart is tested and
supported with Helm v3 (3.3.1 or higher required).

Install Helm by picking one of the options listed under the
[official Helm documentation](https://helm.sh/docs/intro/install/).

## Next steps

Once kubectl and Helm are configured, you can continue to configuring your
[Kubernetes cluster](index.md#cloud-cluster-preparation).

## Additional information

The Distribution Team has a [training presentation for Helm Charts](https://docs.google.com/presentation/d/1CStgh5lbS-xOdKdi3P8N9twaw7ClkvyqFN3oZrM1SNw/present).

### Templates

Templating in Helm is done via golang's [text/template](https://pkg.go.dev/text/template)
and [sprig](https://pkg.go.dev/github.com/Masterminds/sprig?utm_source=godoc%27).

Some information on how all the inner workings behave:

- [Functions and Pipelines](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/)
- [Subcharts and Globals](https://helm.sh/docs/chart_template_guide/subcharts_and_globals/)

### Tips and tricks

Helm repository has some additional information on developing with Helm in its
[tips and tricks section](https://helm.sh/docs/howto/charts_tips_and_tricks/).
