{{/* Returns Pod labels */}}
{{- define "ix.v1.common.podLabels" -}}
  {{- with .Values.controllers.main.pod.labels -}}
    {{- range $k, $v := . }}
{{ $k }}: {{ tpl $v $ }}
    {{- end }}
  {{- end -}}
{{- end -}}
