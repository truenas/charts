{{- define "diskover.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) }}
  {{- $nginx := printf "https://%s-nginx:%v" $fullname .Values.collaboraNetwork.webPort -}}

  {{- if .Values.collaboraNetwork.certificateID }}
configmap:
  elastic-scripts:
    enabled: true
    data:
      placeholder: value
{{- end -}}
