{{/* Service - clusterIP */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.clusterIP" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

  {{- with $objectData.clusterIP }}
clusterIP: {{ tpl . $rootCtx }}
  {{- end -}}

{{- end -}}
