---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Role based access control **(FREE SELF)**

Until Kubernetes 1.7, there were no permissions within a cluster. With the launch of 1.7, there is now a role based access control system ([RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)) which determines what services can perform actions within a cluster.

RBAC affects a few different aspects of GitLab:

- Installation of GitLab using Helm
- Prometheus monitoring
- GitLab Runner
- In-cluster PostgreSQL database (when RBAC is enabled for it)
- Certificate manager

## Checking that RBAC is enabled

Try listing the current cluster roles, if it fails then `RBAC` is disabled

This command will output `false` if `RBAC` is disabled and `true` otherwise

`kubectl get clusterroles > /dev/null 2>&1 && echo true || echo false`

## Service accounts

GitLab chart uses Service accounts to perform certain tasks. These accounts and their associated roles
are created and managed by the chart.

The service accounts are described in the following table. For each service account the table shows:

- The name suffix (the prefix is the release name).
- A short description, e.g. where it is used, what it is used for.
- Associated roles and what level of access it has on which resources. Access level is either read-only (R),
  write-only (W), or read-write (RW). Note that group name of resources are omitted.
- The scope of the roles, which is either the cluster (C) or the namespace (NS). In some instances the scope
  of the roles can be configured with either value (indicated by NS/C)

| Name suffix | Description | Roles | Scope
| ---         | ---         | ---   | ---
| `gitlab-runner` | The GitLab Runner is executed with this account. | Any resource (RW) | NS/C
| `ingress-nginx` | Used by NGINX Ingress to control service access points. | Secret, Pod, Endpoint, Ingress (R); Event (W); ConfigMap, Service (RW) | NS/C
| `shared-secrets` | The job that creates shared secrets runs with this account. (in pre-install/upgrade hook) | Secret (RW) | NS
| `cert-manager` | The job that controls certificate manager runs with this account. | Issuer, Certificate, CertificateRequest, Order (RW)  | NS/C

GitLab chart depends on other charts that they also use RBAC and create their own service accounts and role binding. Here is an overview:

- Prometheus monitoring creates multiple own service accounts by default. They are all associated to cluster level roles. For more information see [Prometheus chart documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus#rbac-configuration).
- Certificate manager creates a service account by default to manage its custom resources along with native resources at the cluster level. For more information see [cert-manager chart RBAC template](https://github.com/jetstack/cert-manager/blob/master/deploy/charts/cert-manager/templates/rbac.yaml).
- When you use in-cluster PostgreSQL database (this is the default) the service account is not enabled. You can enable it but it is only used to run PostgreSQL service and is not associated to any specific role. For more information see [PostgreSQL chart](https://github.com/bitnami/charts/tree/master/bitnami/postgresql).
