{{/* Service - LoadBalancer Spec */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.spec.loadBalancer" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the service
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.spec.loadBalancer" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

type: LoadBalancer
  {{- with $objectData.loadBalancerIP }}
loadBalancerIP: {{ tpl . $rootCtx }}
  {{- end -}}

  {{- with $objectData.loadBalancerSourceRanges }}
loadBalancerSourceRanges:
    {{- range . }}
  - {{ tpl . $rootCtx }}
    {{- end -}}
  {{- end -}}

  {{- include "ix.v1.common.lib.service.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- include "ix.v1.common.lib.service.ipFamily" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
  {{- include "ix.v1.common.lib.service.externalTrafficPolicy" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
{{- end -}}
