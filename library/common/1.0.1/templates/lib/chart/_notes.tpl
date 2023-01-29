{{- define "ix.v1.common.lib.chart.notes" -}}

  {{- include "ix.v1.common.lib.chart.header" . -}}

  {{- include "ix.v1.common.lib.chart.custom" . -}}

  {{- include "ix.v1.common.lib.chart.footer" . -}}

{{- end -}}

{{- define "ix.v1.common.lib.chart.header" -}}
  {{- tpl $.Values.common.notes.header $ | nindent 0 }}
{{- end -}}
{{- define "ix.v1.common.lib.chart.custom" -}}
  {{- tpl $.Values.common.notes.header $ | nindent 0 }}
{{- end -}}
{{- define "ix.v1.common.lib.chart.footer" -}}
  {{- tpl $.Values.common.notes.header $ | nindent 0 }}
{{- end -}}
