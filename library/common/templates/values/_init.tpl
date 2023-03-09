{{/* Merge chart values and the common chart defaults */}}
{{/* The ".common" is the name of the library */}}
{{/* Call this template:
{{ include "ix.v1.common.values.init" $ }}
*/}}

{{- define "ix.v1.common.values.init" -}}
  {{- if .Values.common -}}
    {{- $commonValues := mustDeepCopy .Values.common -}}
    {{- $chartValues := mustDeepCopy (omit .Values "common") -}}
    {{- $mergedValues := mustMergeOverwrite $commonValues $chartValues -}}
    {{- $_ := set . "Values" (mustDeepCopy $mergedValues) -}}
  {{- end -}}
{{- end -}}
