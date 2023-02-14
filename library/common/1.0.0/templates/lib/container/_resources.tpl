{{/* Returns Resources */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.container.resources" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the container.
*/}}
{{- define "ix.v1.common.lib.container.resources" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $resources := $rootCtx.Values.containerOptions.resources -}}

  {{- if $objectData.resources -}}
    {{- $resources = mustMergeOverwrite $resources $objectData.resources -}}
  {{- end -}}

  {{- $resources | toYaml -}}

{{- end -}}
