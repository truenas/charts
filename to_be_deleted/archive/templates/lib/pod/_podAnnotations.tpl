{{/* Returns Pod annotations */}}
{{- define "ix.v1.common.podAnnotations" -}}
  {{- with .Values.controllers.main.pod.annotations -}}
    {{- range $k, $v := . }}
{{ $k }}: {{ tpl $v $ }}
    {{- end }}
  {{- end -}}
{{- end -}}
