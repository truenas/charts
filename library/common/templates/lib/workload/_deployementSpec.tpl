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
  {{- $strategy := $objectData.strategy | default "Recreate" }}
replicas: {{ $objectData.replicas | default 1 }}
revisionHistoryLimit: {{ $objectData.revisionHistoryLimit | default 3 }}
strategy:
  type: {{ $strategy }}
  {{- if and (eq $objectData.strategy "RollingUpdate") $objectData.rollingUpdate -}}
    {{ if (or (hasKey $objectData.rollingUpdate "maxUnavailable") (hasKey $objectData.rollingUpdate "maxSurge")) }}
  rollingUpdate:
      {{- if hasKey $objectData.rollingUpdate "maxUnavailable" }}
    maxUnavailable: {{ $objectData.rollingUpdate.maxUnavailable }}
      {{- end -}}
      {{- if hasKey $objectData.rollingUpdate "maxSurge" }}
    maxSurge: {{ $objectData.rollingUpdate.maxSurge }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
