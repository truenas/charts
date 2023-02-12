{{/* Labels that are used on selectors */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "podName" $podName) }}
podName is the "shortName" of the pod. The one you define in the .Values.workload
*/}}
{{- define "ix.v1.common.lib.metadata.selectorLabels" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectType := .objectType -}}
  {{- $objectName := .objectName }}

{{ printf "%s.name" $objectType }}: {{ $objectName }}
app.kubernetes.io/name: {{ include "ix.v1.common.lib.chart.names.name" $rootCtx }}
app.kubernetes.io/instance: {{ $rootCtx.Release.Name }}
{{- end -}}
