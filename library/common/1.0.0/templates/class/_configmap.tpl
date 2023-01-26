{{/*
Call this template like this;
{{- include "ix.v1.common.class.configmap" (dict "root" $root "values" $values) -}}
$values contains:
  name: string
  labels: dict
  annotations: dict
  contentType: yaml (only supported type)
  data: (data | toYaml)
*/}}
{{- define "ix.v1.common.class.configmap" -}}
  {{- $values := .values -}}
  {{- $root := .root }}

---
apiVersion: {{ include "ix.v1.common.capabilities.configMap.apiVersion" $root }}
kind: ConfigMap
metadata:
  name: {{ $values.name }}
  {{- $labels := (mustMerge ($values.labels | default dict) (include "ix.v1.common.labels" $root | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.labels.render" (dict "root" $root "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end -}}
  {{- $annotations := (mustMerge ($values.annotations | default dict) (include "ix.v1.common.annotations" $root | fromYaml)) -}}
  {{- with (include "ix.v1.common.util.annotations.render" (dict "root" $root "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
data:
  {{- if eq $values.contentType "yaml" }}
    {{- $values.data | nindent 2 }}
  {{- else -}} {{/* This should never happen, unless there is a mistake in the caller of this class */}}
    {{- fail (printf "Invalid content type (%s) for configmap. Valid types are yaml" $values.contentType) -}}
  {{- end -}}
{{- end -}}
