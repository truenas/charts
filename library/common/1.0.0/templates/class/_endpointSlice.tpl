{{/* EndpointSlice Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.endpointSlice" (dict "rootCtx" $ "objectData" $objectData) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData: The service data, that will be used to render the Service object.
*/}}

{{- define "ix.v1.common.class.endpointSlice" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}

  {{- $addressType := $objectData.addressType | default "IPv4" -}}
  {{- if $objectData.addressType -}}
    {{- $addressType = tpl $addressType $rootCtx -}}
  {{- end }}

---
apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- $_ := set $labels "kubernetes.io/service-name" $objectData.name -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
addressType: {{ $addressType }}
ports:
{{- include "ix.v1.common.lib.endpointslice.ports" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
endpoints:
{{- include "ix.v1.common.lib.endpointslice.endpoints" (dict "rootCtx" $rootCtx "objectData" $objectData) | trim | nindent 2 }}
{{- end -}}
