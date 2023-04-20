{{/* Initialiaze values of the chart */}}

{{- define "ix.v1.common.loader.init" -}}

  {{/* Merge chart values and the common chart defaults */}}
  {{- include "ix.v1.common.values.init" . -}}

{{- end -}}
