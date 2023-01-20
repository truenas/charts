{{/* vim: set filetype=mustache: */}}

{{- define "gitlab.application.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end -}}

{{- define "gitlab.standardLabels" -}}
app: {{ template "name" . }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- if .Values.global.application.create }}
{{ include "gitlab.application.labels" . }}
{{- end -}}
{{- end -}}


{{- define "gitlab.selectorLabels" -}}
app: {{ template "name" . }}
release: {{ .Release.Name }}
{{ if .Values.global.application.create -}}
{{ include "gitlab.application.labels" . }}
{{- end -}}
{{- end -}}

{{- define "gitlab.commonLabels" -}}
{{- $commonLabels := merge (pluck "labels" (default (dict) .Values.common) | first) .Values.global.common.labels}}
{{- if $commonLabels }}
{{-   range $key, $value := $commonLabels }}
{{ $key }}: {{ $value | quote }}
{{-   end }}
{{- end -}}
{{- end -}}

{{/* Deprecated, do not use these labels.*/}}
{{- define "gitlab.immutableLabels" -}}
app: {{ template "name" . }}
chart: {{ .Chart.Name }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{ if .Values.global.application.create -}}
{{ include "gitlab.application.labels" . }}
{{- end -}}
{{- end -}}


{{- define "gitlab.nodeSelector" -}}
{{- $nodeSelector := default .Values.global.nodeSelector .Values.nodeSelector -}}
{{- if $nodeSelector }}
nodeSelector:
  {{- toYaml $nodeSelector | nindent 2 }}
{{- end }}
{{- end -}}
