{{/* Common labels shared across objects */}}
{{- define "ix.v1.common.labels" -}}
  {{- include "ix.v1.common.labels.selectorLabels" . -}}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "ix.v1.common.names.chart" . }}
helm-revision: {{ .Release.Revision | quote }}
  {{/* Append global labels */}}
  {{- include "ix.v1.common.util.labels.render" (dict "root" . "labels" .Values.global.labels) -}}
{{- end -}}

{{/* Selector labels shared across objects */}}
{{- define "ix.v1.common.labels.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ix.v1.common.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
