{{/* Service - ClusterIP */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.service.clusterIP" (dict "rootCtx" $rootCtx "objectData" $objectData) -}}
rootCtx: The root context of the service
objectData: The service object data
*/}}

{{- define "ix.v1.common.lib.service.clusterIP" -}}
  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}

type: ClusterIP
  {{- with $objectData.clusterIP }}
clusterIP: {{ tpl . $rootCtx }}
  {{- end -}}
  {{- include "ix.v1.common.lib.service.ipFamily" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 0 }}
{{- end -}}
