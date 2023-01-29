{{/*
Call this template like this;
{{- include "ix.v1.common.class.externalInterface" (dict "values" $values "root" $) -}}
$values contains:
  iface:
  index:
*/}}
{{- define "ix.v1.common.class.externalInterface" -}}
  {{- $values := .values -}}
  {{- $root := .root }}
---
apiVersion: {{ include "ix.v1.common.capabilities.externalInterfaces.apiVersion" . }}
kind: NetworkAttachmentDefinition
metadata:
  name: ix-{{ $root.Release.Name }}-{{ $values.index }}
  {{- $labels := (include "ix.v1.common.labels" $root | fromYaml) -}}
  {{- with (include "ix.v1.common.util.labels.render" (dict "root" $root "labels" $labels) | trim) }}
  labels:
    {{- . | nindent 4 }}
  {{- end }}
  {{- $annotations := (include "ix.v1.common.annotations" $root | fromYaml) -}}
  {{- with (include "ix.v1.common.util.annotations.render" (dict "root" $root "annotations" $annotations) | trim) }}
  annotations:
    {{- . | nindent 4 }}
  {{- end }}
spec:
  config: {{ $values.iface | squote }}
{{- end -}}
