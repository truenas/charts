{{/* Get Certificate Data */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.certificate.getData" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The object data of the certificate
*/}}
{{- define "ix.v1.common.lib.certificate.getData" -}}
  {{- $objectData := .objectData -}}
  {{- $rootCtx := .rootCtx -}}



{{- end -}}
