{{- define "diskover.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}

configmap:
  elastic-scripts:
    enabled: true
    data:
      placeholder: value
{{- end -}}
