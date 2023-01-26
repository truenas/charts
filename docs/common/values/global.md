# Global

## Key: defaults

- Type: `dict`
- Default:

  ```yaml
  global:
    defaults:
      # If not defined on per pod or in ixChartContext, assume this.
      # Empty means NO runtimeClassName
      runtimeClassName: ""
      # If not defined on the pod, assume this
      dnsPolicy: ClusterFirst
      # If no restart Policy is defined, assume this
      restartPolicy: Always
      # If no restart Policy for job is defined, assume this
      jobRestartPolicy: Never
      # If no port Protocol is defined, assume this
      portProtocol: TCP
      # Define the minimum NodePort
      minimumNodePort: 9000
      # If no service Type is defined, assume this
      serviceType: ClusterIP
      # If no PVC Size is defined, assume this
      PVCSize: 1Gi
      # If no VCT Size is defined, assume this
      VCTSize: 999Gi
      # If no PVC type is defined, assume this
      persistenceType: pvc
      # If no validateHostPath key exists in the persistence item, assume this
      validateHostPath: false
      # If no PVC accessMode is defined, assume this
      accessMode: ReadWriteOnce
      # If no PVC retain key is defined, assume this
      # Note, that this adds an annotation for helm whether to delete
      # the resource on uninstall, manually deleting the namespace it will delete
      # the resource no matter what this is set.
      PVCRetain: false
      # Define a storageClassName that will be used for all PVCs by default
      # Leave empty to rely on the node's default storageClass
      storageClass:
      # When SCALE-ZFS is set for storageClass, return this name
      scaleZFSStorageClass:
      # Default security context used for all
      # init/install/upgrade/additional
      # and main containers if not specified
      securityContext:
        runAsNonRoot: true
        runAsUser: 568
        runAsGroup: 568
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
        privileged: false
        capabilities:
          add: []
          drop:
            - ALL
      # Default podSecurityContext, used if
      # no other is specified
      podSecurityContext:
        fsGroup: 568
        supplementalGroups: []
        fsGroupChangePolicy: OnRootMismatch
      # Default Security values, if no others
      # are specified
      security:
        PUID: 568
        UMASK: "002"
      # Whether to inject fixedEnvs on containers
      # Can be overruled per container
      injectFixedEnvs: true
      # Default nvidia Caps will be assigned via
      # environment variable (requires injectFixedEnvs)
      nvidiaCaps:
        - all
      # Default Resources values, if no others
      # are specified, use those
      resources:
        limits:
          cpu: 4000m
          memory: 8Gi
        requests:
          cpu: 10m
          memory: 50Mi
      # If no probe Type is defined, assume this
      probeType: auto
      # If no probe Path is defined, assume this
      probePath: /
      # Default probe timeouts, if no others
      # are specified, use those
      probes:
        liveness:
          spec:
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 5
        readiness:
          spec:
            initialDelaySeconds: 10
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 5
        startup:
          spec:
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 2
            failureThreshold: 60
      # Default job/cronjob values
      job:
        cron:
          concurrencyPolicy: Forbid
          failedJobsHistoryLimit: 1
          successfulJobsHistoryLimit: 3
        backoffLimit: 6
        completionMode: NonIndexed
  ```

- Helm Template: ❌

Can be defined in:

- `.Values.global`.defaults

---

Everything here is default values that common will use,
if nothing is provided from the Chart.

Defaults are there to reduce amount of code needed on each Chart.
It also have default security configuration. Which by default,
aims to result in Chart with the least privileges.

Changing the global defaults per Chart is something that should be avoided.
Every value in the defaults can be changed per Chart, out of the global context.
