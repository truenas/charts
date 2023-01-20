---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Preparing EKS resources **(FREE SELF)**

For a fully functional GitLab instance, you will need a few resources before
deploying the `gitlab` chart.

## Creating the EKS cluster

To get started easier, a script is provided to automate the cluster creation.
Alternatively, a cluster can be created manually as well.

### Scripted cluster creation

A [bootstrap script](https://gitlab.com/gitlab-org/charts/gitlab/blob/master/scripts/eks_bootstrap_script)
has been created to automate much of the setup process for users on EKS. You will need to clone this repository before executing the script.

The script will:

1. Create a new EKS cluster.
1. Setup `kubectl`, and connect it to the cluster.

The script uses [`eksctl`](https://eksctl.io) to initialize the cluster. If it cannot locate it in your PATH, you will need to download and install it manually.

To authenticate, `eksctl` uses the same options as the AWS command line. See the AWS documentation for how to
use [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html), or [configuration files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).

The script reads various parameters from environment variables, or command line arguments and an argument
`up` or `down` for bootstrap and clean up respectively.

The table below describes all variables.

| Variable          | Description                                      | Default value    |
|-------------------|--------------------------------------------------|------------------|
| `REGION`          | The region where your cluster lives              | `us-east-2`      |
| `CLUSTER_NAME`    | The name of the cluster                          | `gitlab-cluster` |
| `CLUSTER_VERSION` | The version of your EKS cluster                  | `1.18`           |
| `NUM_NODES`       | The number of nodes required                     | `2`              |
| `MACHINE_TYPE`    | The type of nodes to deploy                      | `m5.xlarge`      |

Run the script, by passing in your desired parameters. It can work with the
default parameters.

```shell
./scripts/eks_bootstrap_script up
```

The script can also be used to clean up the created EKS resources:

```shell
./scripts/eks_bootstrap_script down
```

### Manual cluster creation

- We recommend a cluster with 8vCPU and 30GB of RAM.

For the most up to date instructions, follow Amazon's
[EKS getting started guide](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).

Administrators may also want to consider the
[new AWS Service Operator for Kubernetes](https://aws.amazon.com/blogs/opensource/aws-service-operator-kubernetes-available/)
to simplify this process.

NOTE:
Enabling the AWS Service Operator requires a method of managing roles within the cluster. The initial
services handling that management task are provided by third party developers. Administrators should
keep that in mind when planning for deployment.

## Persistent Volume Management

There are two methods to manage volume claims on Kubernetes:

- Manually create a persistent volume.
- Automatic persistent volume creation through dynamic provisioning.

We currently recommend using manual provisioning of persistent volumes. Amazon EKS
clusters default to spanning multiple zones. Dynamic provisioning, if not configured
to use a storage class locked to a particular zone leads to a scenario where pods may
exist in a different zone from storage volumes and be unable to access data.

Administrators who need to deploy in multiple zones should familiarize themselves
with [how to set up cluster storage](../storage.md) and review
[Amazon's own documentation on storage classes](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)
when defining their storage solution.

## External Access to GitLab

By default, installing the GitLab Chart will deploy an Ingress which will create an associated
Elastic Load Balancer (ELB). Since the DNS names of the ELB cannot be known
ahead of time, it's difficult to utilize [Let's Encrypt](https://letsencrypt.org/) to automatically provision
HTTPS certificates.

We recommend [using your own certificates](../tls.md#option-2-use-your-own-wildcard-certificate),
and then mapping your desired DNS name to the created ELB using a CNAME
record. Since the ELB must be created first before its hostname can be
retrieved, follow the next instructions to install GitLab.

NOTE:
For environments where AWS LoadBalancers are required,
[Amazon's Elastic Load Balancers](https://docs.aws.amazon.com/eks/latest/userguide/load-balancing.html)
require specialized configuration. See [Cloud provider LoadBalancers](../../charts/globals.md#cloud-provider-loadbalancers)

## Next Steps

Continue with the [installation of the chart](../deployment.md) once you
have the cluster up and running. Set the domain name via the
`global.hosts.domain` option, but omit the static IP setting via the
`global.hosts.externalIP` option unless you plan on using an existing
Elastic IP.

After the Helm install, you can fetch your ELB's hostname to place in
the CNAME record with the following:

```shell
kubectl get ingress/RELEASE-webservice-default -ojsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

`RELEASE` should be substituted with the release name used in `helm install <RELEASE>`.
