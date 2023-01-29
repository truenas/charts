{{/* Configmap Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.configmap" (dict "objectData" $objectData "rootCtx" $) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData:
  name: The name of the configmap.
  labels: The labels of the configmap.
  annotations: The annotations of the configmap.
  data: The data of the configmap.
*/}}

{{- define "ix.v1.common.class.configmap" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
data:
  {{- tpl (toYaml $objectData.data) $rootCtx | nindent 2 }}
{{- end -}}
