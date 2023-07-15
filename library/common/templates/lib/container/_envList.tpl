{{/* Returns Env List */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.envList" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.envList" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- range $env := $objectData.envList -}}
    {{- if not $env.name -}}
      {{- fail "Container - Expected non-empty <envList.name>" -}}
    {{- end -}} {{/* Empty value is valid */}}
    {{- include "ix.v1.common.helper.container.envDupeCheck" (dict "rootCtx" $rootCtx "objectData" $objectData "source" "envList" "key" $env.name) -}}
    {{- $value := $env.value -}}
    {{- if kindIs "string" $env.value -}}
      {{- $value = tpl $env.value $rootCtx -}}
    {{- end }}
- name: {{ $env.name | quote }}
  value: {{ include "ix.v1.common.helper.makeIntOrNoop" $value | quote }}
  {{- end -}}
{{- end -}}
