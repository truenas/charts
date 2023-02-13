{{/* Deployment Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.deploymentSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData:
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The deployment strategy to use to replace existing pods with new ones.
*/}}
{{- define "ix.v1.common.lib.workload.deploymentSpec" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
replicas: {{ $objectData.replicas | default 1 }}
revisionHistoryLimit: {{ $objectData.revisionHistoryLimit | default 3 }}
strategy:
  type: {{ $objectData.strategy | default "Recreate" }}
  {{- if eq $objectData.strategy "RollingUpdate" }}
    {{- if not $objectData.rollingUpdate -}} {{/* Create the key if it does not exist, to avoid nil pointers */}}
      {{- $_ := set $objectData "rollingUpdate" dict -}}
    {{- end }}
  rollingUpdate:
    maxUnavailable: {{ $objectData.rollingUpdate.maxUnavailable | default $rootCtx.Values.fallbackDefaults.maxUnavailable }}
    maxSurge: {{ $objectData.rollingUpdate.maxSurge | default $rootCtx.Values.fallbackDefaults.maxSurge }}
  {{- end -}}
{{- end -}}
