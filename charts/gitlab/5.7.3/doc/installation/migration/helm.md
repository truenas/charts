---
stage: Enablement
group: Distribution
info: To determine the technical writer assigned to the Stage/Group associated with this page, see https://about.gitlab.com/handbook/engineering/ux/technical-writing/#designated-technical-writers
---

# Migrating from Helm v2 to Helm v3 **(FREE SELF)**

[Helm v2 was officially deprecated](https://helm.sh/blog/helm-v2-deprecation-timeline/) in November of 2020. Starting from GitLab Helm Chart version 5.0 (GitLab App version 14.0), installation and upgrades using Helm v2.x are no longer supported. To get
future GitLab updates, you will need to migrate to Helm v3.

## Changes between Helm v2 and Helm v3

Helm v3 introduces a lot of changes that are not backwards compatible with Helm v2. Some of the major changes include the removal of Tiller requirements and how they store releases information on the cluster. Read more in the [Helm v3 changes overview](https://helm.sh/docs/topics/v2_v3_migration/#overview-of-helm-3-changes) and the [changes since Helm v2 FAQ](https://helm.sh/docs/faq/changes_since_helm2/).

The Helm Chart you use to deploy the application might not be compatible with the newer / older versions of Helm. If you have multiple applications deployed and managed with Helm v2, you will need to find out if they are compatible with Helm v3 in case you want to convert them as well. GitLab Helm Chart supports Helm v3.0.2 or higher starting with version v3.0.0 of GitLab Helm Chart. Helm v2 is no longer supported.

From the standpoint of the application that is currently running, nothing is changed when you perform the migration from Helm v2 to v3. It's generally pretty safe to perform the Helm v2 to v3 migration, however, be sure to take backups of Helm v2 as a precaution.

## How to migrate from Helm v2 to Helm v3

You can use the [Helm 2to3 plugin](https://github.com/helm/helm-2to3) to migrate GitLab releases from
Helm v2 to Helm v3. For a more detailed explanation with some examples about this migration plugin, refer to Helm blog post: [How to migrate from Helm v2 to Helm v3](
https://helm.sh/blog/migrate-from-helm-v2-to-helm-v3/).

If you have multiple people managing your GitLab Helm installation, you may need to do `helm3 2to3 move config` on each local machine. You will only need to do `helm3 2to3 convert` once.

## Known Issues

### "UPGRADE FAILED: cannot patch" error is shown after the migration

After migration the **subsequent upgrades may fail** with an error similar to the following:

```shell
Error: UPGRADE FAILED: cannot patch "..." with kind Deployment: Deployment.apps "..." is invalid: spec.selector:
Invalid value: v1.LabelSelector{...}: field is immutable
```

or

```shell
Error: UPGRADE FAILED: cannot patch "..." with kind StatefulSet: StatefulSet.apps "..." is invalid:
spec: Forbidden: updates to statefulset spec for fields other than 'replicas', 'template', and 'updateStrategy' are forbidden
```

This is due to known issues with Helm 2 to 3 migration in [Cert Manager](https://github.com/jetstack/cert-manager/issues/2451)
and [Redis](https://github.com/bitnami/charts/issues/3482) dependencies. In a nutshell, the `heritage` label
on some Deployments and StatefulSets are immutable and can not be changed from `Tiller` (set by Helm 2) to `Helm`
(set by Helm 3). So they must be replaced _forcefully_.

To work around this use the following instructions:

NOTE:
These instructions _forcefully replace resources_, notably Redis StatefulSet.
You need to ensure that the attached data volume to this StatefulSet is safe and remains intact.

1. Replace cert-manager Deployments (when enabled).

```shell
kubectl get deployments -l app=cert-manager -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true -f -
kubectl get deployments -l app=cainjector -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true -f -
```

1. (Optional) Set `persistentVolumeReclaimPolicy` to `Retain` on the PV that is claimed by Redis StatefulSet.
   This is to ensure that the PV won't be deleted inadvertently.

```shell
kubectl patch pv <PV-NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

1. Set `heritage` label of the existing Redis PVC to `Helm`.

```shell
kubectl label pvc -l app=redis --overwrite heritage=Helm
```

1. Replace Redis StatefulSet **without cascading**.

```shell
kubectl get statefulsets.apps -l app=redis -o yaml | sed "s/Tiller/Helm/g" | kubectl replace --force=true --cascade=false -f -
```

### RBAC issues after the migration when running Helm upgrade

You may face the following error when running Helm upgrade after the conversion has been completed:

```shell
Error: UPGRADE FAILED: pre-upgrade hooks failed: warning: Hook pre-upgrade gitlab/templates/shared-secrets/rbac-config.yaml failed: roles.rbac.authorization.k8s.io "gitlab-shared-secrets" is forbidden: user "your-user-name@domain.tld" (groups=["system:authenticated"]) is attempting to grant RBAC permissions not currently held:
{APIGroups:[""], Resources:["secrets"], Verbs:["get" "list" "create" "patch"]}
```

Helm2 used the Tiller service account to perform such operations. Helm3 does not use Tiller anymore, and your user account should have proper RBAC permissions to run the command even if you are running `helm upgrade` as a cluster admin. To grant full RBAC permissions to yourself, run:

```shell
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=your-user-name@domain.tld
```

After that, `helm upgrade` should work fine.
