{{- define "es.schema" -}}
  {{- $protocol := "http" -}}
  {{- if .Values.esNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end -}}
  {{- $protocol -}}
{{- end -}}
