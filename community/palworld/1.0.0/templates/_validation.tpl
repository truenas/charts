{{- define "palworld.validation" -}}
  {{- range $param := .Values.palworldConfig.gameParams -}}
    {{- if hasPrefix "port=" $param -}}
      {{- fail "PalWorld - [port=] param is automatically adjusted from the Server Port field" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
