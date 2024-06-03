{{- define "tailscale.args" -}}
  {{- $args := list -}}

  {{- with .Values.tailscaleConfig.hostname -}}
    {{- $args = mustAppend $args (printf "--hostname %v" .) -}}
  {{- end -}}

  {{- with .Values.tailscaleConfig.advertiseExitNode -}}
    {{- $args = mustAppend $args "--advertise-exit-node" -}}
  {{- end -}}

  {{- range $arg := .Values.tailscaleConfig.extraArgs -}}
    {{- $args = mustAppend $args $arg -}}
  {{- end -}}

  {{- if $args -}}
    {{- $args | join " " -}}
  {{- end -}}
{{- end -}}

{{- define "tailscale.validation" -}}
  {{- if not .Values.tailscaleConfig.authkey -}}
    {{- fail "Tailscale - Expected non-empty [Auth Key]" -}}
  {{- end -}}

  {{- with .Values.tailscaleConfig.hostname -}}
    {{- if not (mustRegexMatch "^[a-z0-9-]+$" .) -}}
      {{- fail "Tailscale - Expected [Hostname] to match the following - [All lowercase, numbers, dashes, No spaces, No underscores]" -}}
    {{- end -}}
  {{- end -}}

{{- end -}}
