{{/* Labels that are added to all objects */}}
{{/* Call this template:
{{ include "ix.v1.common.lib.metadata.allLabels" $ }}
*/}}
{{- define "ix.v1.common.lib.metadata.allLabels" -}}
helm.sh/chart: {{ include "ix.v1.common.lib.chart.names.chart" . }}
helm-revision: {{ .Release.Revision | quote }}
app.kubernetes.io/name: {{ include "ix.v1.common.lib.chart.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app: {{ include "ix.v1.common.lib.chart.names.chart" . }}
release: {{ .Release.Name }}
{{- include "ix.v1.common.lib.metadata.globalLabels" . }}
{{- end -}}
