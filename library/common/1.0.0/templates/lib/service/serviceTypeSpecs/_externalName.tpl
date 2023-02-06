{{/* Service - ExternalName Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.spec.externalName" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the service
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.spec.externalName" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

  {{- if not $objectData.externalName -}}
    {{- fail "Service - Expected non-empty <externalName> on ExternalName service type." -}}
  {{- end }}

type: ExternalName
externalName: {{ tpl $objectData.externalName $rootCtx }}
publishNotReadyAddresses: {{ include "ix.v1.common.lib.service.publishNotReadyAddresses" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim }}
  {{- with (include "ix.v1.common.lib.service.externalIPs" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim) }}
externalIPs:
    {{- . | nindent 2 }}
  {{- end }}
  {{- include "ix.v1.common.lib.service.sessionAffinity" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- include "ix.v1.common.lib.service.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- include "ix.v1.common.lib.service.externalTrafficPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
{{- end -}}
