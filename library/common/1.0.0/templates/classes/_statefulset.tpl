{{/* StatefulSet Class */}}
{{/* Call this template:
{{ include "ix.v1.common.class.deployment" (dict "objectData" $objectData "rootCtx" $) }}

rootCtx: The root context of the template. It is used to access the global context.
objectData: The object data to be used to render the StatefulSet.
*/}}

{{- define "ix.v1.common.class.statefulset" -}}

  {{- $rootCtx := .rootCtx -}}
  {{- $objectData := .objectData -}}
  {{- include "ix.v1.common.lib.controller.statefulsetValidation" (dict "objectData" $objectData) }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $objectData.name }}
  {{- $labels := (mustMerge ($objectData.labels | default dict) (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($objectData.annotations | default dict) (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)) -}}
  {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  {{- include "ix.v1.common.lib.controller.statefulsetSpec" (dict "rootCtx" $rootCtx "objectData" $objectData) | nindent 2 }}
  selector:
    matchLabels:
      {{- include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "podName" $objectData.name) | nindent 6 }}
  template:
    metadata:
        {{- $labels := (mustMerge ($objectData.podSpec.labels | default dict)
                                  (include "ix.v1.common.lib.metadata.allLabels" $rootCtx | fromYaml)
                                  (include "ix.v1.common.lib.metadata.podLabels" $rootCtx | fromYaml)
                                  (include "ix.v1.common.lib.metadata.selectorLabels" (dict "rootCtx" $rootCtx "podName" $objectData.name) | fromYaml)) -}}
        {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "labels" $labels) | trim) }}
      labels:
        {{- . | nindent 8 }}
        {{- end -}}
        {{- $annotations := (mustMerge ($objectData.podSpec.annotations | default dict)
                                        (include "ix.v1.common.lib.metadata.allAnnotations" $rootCtx | fromYaml)
                                        (include "ix.v1.common.lib.metadata.podAnnotations" $rootCtx | fromYaml)) -}}
        {{- with (include "ix.v1.common.lib.metadata.render" (dict "rootCtx" $rootCtx "annotations" $annotations) | trim) }}
      annotations:
        {{- . | nindent 8 }}
        {{- end }}
  spec:
    {{- include "ix.v1.common.lib.controller.pod" (dict "rootCtx" $rootCtx "objectData" $objectData.podSpec) -}}
{{- end -}}
