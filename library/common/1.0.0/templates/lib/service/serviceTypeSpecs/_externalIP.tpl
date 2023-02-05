{{/* Service - ExternalIP Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.spec.externalIP" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the service
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.spec.externalIP" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

  {{- include "ix.v1.common.lib.service.externalTrafficPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
{{- end -}}
