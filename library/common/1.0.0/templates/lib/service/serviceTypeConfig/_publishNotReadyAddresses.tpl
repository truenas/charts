{{/* Service - publishNotReadyAddresses */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.publishNotReadyAddresses" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.publishNotReadyAddresses" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

  {{- $publishAddr := false -}}

  {{- if (kindIs "bool" $objectData.publishNotReadyAddresses) -}}
    {{- $publishAddr = $objectData.publishNotReadyAddresses -}}
  {{- end -}}

  {{- $publishAddr -}}
{{- end -}}
