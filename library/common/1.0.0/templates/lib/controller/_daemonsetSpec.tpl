{{/* DaemonSet Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.controller.daemonsetSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the template. It is used to access the global context.
objectData:
  replicas: The number of replicas.
  revisionHistoryLimit: The number of old ReplicaSets to retain to allow rollback.
  strategy: The daemonset strategy to use to replace existing pods with new ones.
*/}}
{{- define "ix.v1.common.lib.controller.daemonsetSpec" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}
revisionHistoryLimit: {{ $objectData.revisionHistoryLimit | default 3 }}
updateStrategy:
  type: {{ $objectData.strategy | default "RollingUpdate" }}
  {{- if and
        (eq $objectData.strategy "RollingUpdate")
        $objectData.rollingUpdate
        (or $objectData.rollingUpdate.maxUnavailable $objectData.rollingUpdate.maxSurge) }}
  rollingUpdate:
    {{- with $objectData.rollingUpdate.maxUnavailable }}
    maxUnavailable: {{ .}}
    {{- end -}}
    {{- with $objectData.rollingUpdate.maxSurge }}
    maxSurge: {{ . }}
    {{- end -}}
  {{- end -}}
{{- end -}}
