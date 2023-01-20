---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#assignments
---

# Using the GitLab-Grafana chart **(FREE SELF)**

The `gitlab-grafana` subchart adapts the [`grafana/grafana`](https://artifacthub.io/packages/helm/grafana/grafana)
chart to operate correctly with the same level of configuration as the Omnibus
GitLab install. In addition, the installation of Grafana allows additional
dashboards to be installed by the end user and be incorporated with the
GitLab supplied dashboards.

## Requirements

This chart depends on the `grafana/grafana` chart which is usually installed
by the `GitLab` meta chart. In addition, Kubernetes Ingress support is
needed to properly route the Grafana requests using the `/-/grafana` path.

## Design Choices

Because of Helm limitations it is not possible to configure the Grafana
chart with knowledge of a dynamic name for the initial password Secret.
As a result a statically named Secret is created to contain the initial
password. This Secret is named `gitlab-grafana-initial-password`.

The same issue exists for the ConfigMap that contains the script that
is used to inject the initial password into the Grafana container. That
ConfigMap is named `gitlab-grafana-import-secret`.

Both the initial password Secret and the import script ConfigMap are
mounted into the Grafana container (`/tmp/initial` and `/tmp/scripts`
respectively) and the container command line is augmented to use both
of these objects to securely expose the initial password to the
Grafana server. Modification of the container command line will
generally prevent the initial password from being injected into the
Grafana server environment.

## Configuration

There are no required settings, it should work out of the box if you deploy
all of the charts together. The administrator credentials are created by
the `shared-secrets` Job and the administrator username is set to `root`.
Password for Grafana's root user can be extracted by the following command:

```shell
kubectl get secret gitlab-grafana-initial-password -ojsonpath='{.data.password}' | base64 --decode ; echo
```

## Installation command line options

| Parameter             | Default | Description                                                          |
|-----------------------|---------|----------------------------------------------------------------------|
| `common.labels`       | `{}`    | Supplemental labels that are applied to all objects created by this chart.  |
| `ingress.apiVersion`  |         | Value to use in the `apiVersion` field. |
| `ingress.tls`         | `{}`    | Hash of Ingress TLS settings if GitLab cert manager is not installed |
| `ingress.annotations` | `{}`    | Additional annotations to add to Grafana Ingress resource            |

## Dashboard Support

Grafana dashboards are automatically discovered from the ConfigMaps in
the deployed namespace. If a ConfigMap has been created with the
`gitlab_grafana_dashboard` label set to `true`, then the JSON encoded
dashboard in the ConfigMap will be imported into Grafana. This import happens
once (when Grafana is restarted) and any changes to the dashboard will not be
written back to the ConfigMap.

There are currently no dashboards created when the chart is installed. Any
user created dashboards can be imported by creating a ConfigMap using the
`gitlab_grafana_dashboard` label and managing the ConfigMap themselves.

## Datasource support

Datasources may be created in the same manner as the dashboards by adding
the `gitlab_grafana_datasource` label. This chart will add a ConfigMap
to direct Grafana to use the embedded Prometheus metrics.
