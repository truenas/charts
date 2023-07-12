{{- define "ix.v1.common.helper.makeIntOrNoop" -}}
  {{- $value := . -}}

  {{/* Match scientific notation numbers */}}
  # FIXME: needs better regex
  {{- if (mustRegexMatch "^[1-9][0-9]+e\\+[0-9]+$" (toString $value)) -}}
    {{- $value | int -}}
  {{- else -}}
    {{- $value -}}
  {{- end -}}
{{- end -}}
