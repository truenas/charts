{{- define "palworld.set.params" -}}
  {{- range $param := .Values.palworldConfig.gameParams -}}
    {{- if hasPrefix "port=" $param -}}
      {{- fail "PalWorld - [port=] param is automatically adjusted from the Server Port field" -}}
    {{- end -}}
  {{- end -}}

  {{- $params := (prepend .Values.palworldConfig.gameParams (printf "port=%v" .Values.palworldNetwork.serverPort)) -}}
  {{- $_ := set .Values.palworldConfig "gameParams" $params -}}

  {{/* Handle upgrades from versions that did not had such dicts */}}
  {{- if not .Values.palworldConfig.server -}}
    {{- $_ := set .Values.palworldConfig "server" dict -}}
  {{- end -}}
  {{- if not .Values.palworldConfig.backup -}}
    {{- $_ := set .Values.palworldConfig "backup" dict -}}
  {{- end -}}

  {{- $reservedKeys := list
    "RCONEnabled" "RCONPort" "PublicPort" "ServerName"
    "ServerDescription" "ServerPassword" "AdminPassword"
  -}}

  {{- range $item := .Values.palworldConfig.iniKeys }}
    {{- if (mustHas $item.key $reservedKeys) -}}
      {{- fail (printf "PalWorld - [%v] is a reserved key." $item.key) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
