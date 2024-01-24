{{- define "palworld.set.params" -}}
  {{- range $param := .Values.palworldConfig.gameParams -}}
    {{- if hasPrefix "port=" $param -}}
      {{- fail "PalWorld - [port=] param is automatically adjusted from the Server Port field" -}}
    {{- end -}}
  {{- end -}}

  {{- $params := (prepend .Values.palworldConfig.gameParams (printf "port=%v" .Values.palworldNetwork.serverPort)) -}}
  {{- $_ := set .Values.palworldConfig "gameParams" $params -}}
{{- end -}}
