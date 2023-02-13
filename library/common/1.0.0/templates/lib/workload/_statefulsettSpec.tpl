{{/* StatefulSet Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.workload.statefulsetSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData:
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The statefulset strategy to use to replace existing pods with new ones.
*/}}
{{- define "ix.v1.common.lib.workload.statefulsetSpec" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
replicas: {{ $objectData.replicas | default 1 }}
revisionHistoryLimit: {{ $objectData.revisionHistoryLimit | default 3 }}
serviceName: {{ $objectData.name }}
updateStrategy:
  type: {{ $objectData.strategy | default "RollingUpdate" }}
  {{- if eq $objectData.strategy "RollingUpdate" }}
  rollingUpdate:
    {{- if not $objectData.rollingUpdate -}} {{/* Create the key if it does not exist, to avoid nil pointers */}}
      {{- $_ := set $objectData "rollingUpdate" dict -}}
    {{- end }}
    maxUnavailable: {{ $objectData.rollingUpdate.maxUnavailable | default $rootCtx.Values.fallbackDefaults.maxUnavailable }}
    partition: {{ $objectData.rollingUpdate.partition | default $rootCtx.Values.fallbackDefaults.partition }}
  {{- end -}}
{{- end -}}
