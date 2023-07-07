{{- define "rsync.validation" -}}
  {{- $reservedParams := (list
                          "port" "use chroot" "pid file"
                          "max connections" "log file"
                          ) -}}

  {{- range .Values.rsyncConfig.auxParams -}}
    {{- include "rsync.aux.validation" (dict "aux" .) -}}

    {{- if mustHas .param $reservedParams -}}
      {{- fail (printf "Rsync - Overriding parameter [%v] is not allowed." .param) -}}
    {{- end -}}
  {{- end -}}

  {{- if not .Values.rsyncModules -}}
    {{- fail "Rsync - At least one module must be configured." -}}
  {{- end -}}
{{- end -}}

{{- define "rsync.module.validation" -}}
  {{- $mod := .mod -}}
  {{- if not $mod.name -}}
    {{- fail "Rsync - [Module Name] is required." -}}
  {{- end -}}

  {{- if not (mustRegexMatch "^[a-zA-Z0-9]+([_-]*[a-zA-Z0-9]+)+$" $mod.name) -}}
    {{- $allow := "Can include [Letters (a-z, A-Z), Numbers (0,9), Underscore (_), Dash (-)]" -}}
    {{- $disallow := "But cannot start or end with [Underscore (_), Dash (-), Dot (.)]" -}}
    {{- fail (printf "Rsync - Module Name [%v] has invalid naming format. %v %v" $mod.name $allow $disallow) -}}
  {{- end -}}

  {{- if not $mod.hostPath -}}
    {{- fail (printf "Rsync - [Host Path] on module [%v] is required." $mod.name) -}}
  {{- end -}}

  {{- $modes := (list "RO" "RW" "WO") -}}
  {{- if not (mustHas $mod.accessMode $modes) -}}
    {{- fail (printf "Rsync - [Access Mode] must be one of [%v] on module [%v], but got [%v]." (join ", " $modes) $mod.name $mod.accessMode) -}}
  {{- end -}}

  {{- if kindIs "invalid" $mod.maxConnections -}}
    {{- fail (printf "Rsync - [Max Connections] on module [%v] is required." $mod.name) -}}
  {{- end -}}

  {{- if kindIs "invalid" $mod.uid -}}
    {{- fail (printf "Rsync - [User] on module [%v] is required." $mod.name) -}}
  {{- end -}}

  {{- if kindIs "invalid" $mod.gid -}}
    {{- fail (printf "Rsync - [Group] on module [%v] is required." $mod.name) -}}
  {{- end -}}

  {{- range $entry := $mod.hostsAllow -}}
    {{- if not $entry -}}
      {{- fail (printf "Rsync - Entry [%v] in [Hosts Allow] on module [%v] cannot be empty." $entry $mod.name) -}}
    {{- end -}}
  {{- end -}}

  {{- range $entry := $mod.hostsDeny -}}
    {{- if not $entry -}}
      {{- fail (printf "Rsync - Entry [%v] in [Hosts Deny] on module [%v] cannot be empty." $entry $mod.name) -}}
    {{- end -}}
  {{- end -}}

  {{- range $mod.auxParams -}}
    {{- include "rsync.aux.validation" (dict "aux" .) -}}
  {{- end -}}
{{- end -}}

{{- define "rsync.aux.validation" -}}
  {{- $aux := .aux -}}
  {{- if not $aux.param -}}
    {{- fail "Rsync - Parameter name is required." -}}
  {{- end -}}

  {{- if not $aux.value -}}
    {{- fail (printf "Rsync - Value on parameter [%v] is required." $aux.param) -}}
  {{- end -}}
{{- end -}}
