{{- define "terraria.configuration" -}}
  {{ include "terraria.validation" $ }}
  {{ $sizes := (dict "small" 1 "medium" 2 "large" 3) }}
  {{ $difficutlies := (dict "normal" 0 "expert" 1 "master" 2 "journey" 3) }}
  {{ $flags := (list "-port" "-world" "-maxplayers" "-password" "-secure" "-forceupdate" "-worldevil" "-difficulty" "-autocreate" "-seed") }}
{{/* worldevil, dificulty and autocreate flags are only used
    when a world is generated. According to docs server will
    ingore them if a world exists, so we can safely pass
    them all the time and let server handle it.
    Also -autocreate must come before other flags.
*/}}
- -autocreate
- {{ get $sizes .Values.terrariaConfig.worldSize | quote }}
- -worldevil
- {{ .Values.terrariaConfig.worldEvil | quote }}
- -difficulty
- {{ get $difficutlies .Values.terrariaConfig.worldDifficulty | quote }}
{{ with .Values.terrariaConfig.worldSeed }}
- -seed
- {{ . | quote }}
{{ end }}
- -port
- {{ .Values.terrariaNetwork.serverPort | quote }}
- -world
- {{ printf "/root/.local/share/Terraria/Worlds/%s.wld" .Values.terrariaConfig.worldName | quote }}
- -maxplayers
- {{ .Values.terrariaConfig.maxPlayers | quote }}
{{ with .Values.terrariaConfig.password }}
- -password
- {{ . | quote }}
{{ end }}
{{ if .Values.terrariaConfig.secure }}
- -secure
{{ end }}
{{ if .Values.terrariaConfig.forceUpdate }}
- -forceupdate
{{ end }}
{{ range $arg := .Values.terrariaConfig.additionalArgs }}
  {{ if (mustHas $arg.key $flags) }}
    {{ fail (printf "Terraria - Argument [%s] is already handled by the app, please use the corresponding field instead" $arg.key) }}
  {{ end }}
  - {{ $arg.key | quote }}
  {{ with $arg.value }}
  - {{ . | quote }}
  {{ end }}
{{ end }}
{{- end -}}

{{- define "terraria.validation" -}}

  {{- if not (mustRegexMatch "^[a-zA-Z0-9-]+$" .Values.terrariaConfig.worldName) -}}
    {{- fail "Terraria - Expected World Name to only have [letters, numbers, dashes]" -}}
  {{- end -}}

  {{- if not .Values.terrariaConfig.maxPlayers -}}
    {{- fail "Terraria - Expected non-empty Max Players" -}}
  {{- end -}}

  {{- if gt (int .Values.terrariaConfig.maxPlayers) 255 -}}
    {{- fail "Terraria - Expected Max Players to be at most 255" -}}
  {{- end -}}

  {{- $evils := (list "crimson" "corrupt" "random") -}}
  {{- if not (mustHas .Values.terrariaConfig.worldEvil $evils) -}}
    {{- fail (printf "Terraria - Expected World Evil to be one of [%s], but got [%s]" (join ", " $evils) .Values.terrariaConfig.worldEvil) -}}
  {{- end -}}

  {{- $sizes := (list "small" "medium" "large") -}}
  {{- if not (mustHas .Values.terrariaConfig.worldSize $sizes) -}}
    {{- fail (printf "Terraria - Expected World Size to be one of [%s], but got [%s]" (join ", " $sizes) .Values.terrariaConfig.worldSize) -}}
  {{- end -}}

  {{- $difficutlies := (list "normal" "expert" "master" "journey") -}}
  {{- if not (mustHas .Values.terrariaConfig.worldDifficulty $difficutlies) -}}
    {{- fail (printf "Terraria - Expected World Difficulty to be one of [%s], but got [%s]" (join ", " $difficutlies) .Values.terrariaConfig.worldDifficulty) -}}
  {{- end -}}

{{- end -}}
