{{- define "mineos.validation" -}}
  {{- $start := (.Values.mineosNetwork.mineosPortRangeStart | int) -}}
  {{- $end := (.Values.mineosNetwork.mineosPortRangeEnd | int) -}}

  {{- if gt $start $end -}}
    {{- fail "MineOS - Port range start cannot be greater than port range end." -}}
  {{- end -}}

  {{- if gt (sub $end $start) 10 -}}
    {{- fail "MineOS - Port range is too large. Max 10 ports are allowed." -}}
  {{- end -}}

  {{- if not (mustRegexMatch "^[a-zA-Z0-9]+$" .Values.mineosConfig.username) -}}
    {{- fail "MineOS - Username can only contain alphanumeric characters [0-9, a-z, A-Z]." -}}
  {{- end -}}

{{- end -}}
