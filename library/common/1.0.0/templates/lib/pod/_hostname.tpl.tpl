{{/* Returns Host Name */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.pod.hostname" (dict "rootCtx" $ "objectData" $objectData) }}
rootCtx: The root context of the chart.
objectData: The object data to be used to render the Pod.
*/}}
{{- define "ix.v1.common.lib.pod.hostname" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $hostname := "" -}}

  {{- with $objectData.podSpec.hostname -}}
    {{- $hostname = tpl . $rootCtx -}}
  {{- end -}}

  {{- if $hostname -}}
    {{- include "ix.v1.common.lib.chart.names.validation" (dict "name" $hostname) -}}
  {{- end -}}

  {{- $hostname -}}
{{- end -}}
