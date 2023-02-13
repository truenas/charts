{{/* Returns exec action */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.actions.exec" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.actions.exec" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
exec:
  command:
    {{- include "ix.v1.common.lib.container.command" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 4}}
{{- end -}}
