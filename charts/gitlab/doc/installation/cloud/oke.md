---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Preparing OKE resources **(FREE SELF)**

For a fully functional GitLab instance, you need a few resources before
deploying the `gitlab` chart to [Oracle Container Engine for Kubernetes (OKE)](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm). Check how to [prepare](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengprerequisites.htm) your Oracle Cloud Infrastructure tenancy before creating the OKE cluster.

## Creating the OKE cluster

To provision the Kubernetes cluster manually, follow the
[OKE instructions](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke.htm). Check the list of compute [shapes](https://docs.oracle.com/en-us/iaas/Content/ContEng/Reference/contengimagesshapes.htm#shapes) available for worker nodes supported by OKE.

A cluster with 4 OCPUs and 30GB of RAM is recommended.

### External access to GitLab

By default, the GitLab Chart deploys an Ingress Controller which creates an
Oracle Cloud Infrastructure Public Load Balancer with 100Mbps shape. The Load
Balancer service assigns a floating public IP address which doesn't come from
the host subnet.

To change the shape and other configurations (port, SSL, security lists, etc.)
during the installation of the chart, you can use the following command line argument
`nginx-ingress.controller.service.annotations`. For example, to specify a
Load Balancer with a 400Mbps shape:

```shell
--set nginx-ingress.controller.service.annotations."service\.beta\.kubernetes\.io/oci-load-balancer-shape"="400Mbps"
```

Once deployed, you can check the annotations associated with the Ingress controller service:

```plaintext
$ kubectl get service gitlab-nginx-ingress-controller -o yaml

apiVersion: v1
kind: Service
metadata:
  annotations:
    ...
    service.beta.kubernetes.io/oci-load-balancer-shape: 400Mbps
    ...
```

Check the [OKE Load Balancer documentation](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm) for more information.

## Next steps

Once you have the cluster up and running, continue with the
[installation of the chart](../deployment.md). Set the DNS domain name via the
`global.hosts.domain` option, but omit the static IP setting via the
`global.hosts.externalIP` option.

After completing the deployment, you can query the Load Balancer's IP address to associate with the DNS record type:

```shell
kubectl get ingress/<RELEASE>-webservice-default -ojsonpath='{.status.loadBalancer.ingress[0].ip}'
```

`<RELEASE>` should be substituted with the release name used in `helm install <RELEASE>`.
