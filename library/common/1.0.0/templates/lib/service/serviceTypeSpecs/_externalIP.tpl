{{/* Service - ExternalIP Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.spec.externalIP" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the chart.
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.spec.externalIP" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

publishNotReadyAddresses: {{ include "ix.v1.common.lib.service.publishNotReadyAddresses" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim }}
  {{- with (include "ix.v1.common.lib.service.externalIPs" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
externalIPs:
    {{- . | nindent 2 }}
  {{- end -}}
  {{- include "ix.v1.common.lib.service.sessionAffinity" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- include "ix.v1.common.lib.service.externalTrafficPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
{{- end -}}
