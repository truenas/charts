{{/* Contains functions for generating names */}}

{{/* Returns the name of the Chart */}}
{{- define "ix.common.lib.chart.names.name" -}}

  {{- .Chart.Name | trunc 63 | trimSuffix "-" -}}

{{- end -}}

{{/* Returns the fullname of the Chart */}}
{{- define "ix.common.lib.chart.names.fullname" -}}

  {{- $name := include "ix.common.lib.chart.names.name" . -}}

  {{- if contains $name .Release.name -}}
    {{- $name = .Release.Name -}}
  {{- else -}}
    {{- $name = printf "%s-%s" .Release.Name $name -}}
  {{- end -}}

  {{- $name | trunc 63 | trimSuffix "-" -}}

{{- end -}}
