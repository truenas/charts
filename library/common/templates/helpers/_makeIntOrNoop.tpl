{{- define "ix.v1.common.helper.makeIntOrNoop" -}}
  {{- $value := . -}}

  {{/* Anything with numbers, except those that start with 0. eg UMASK */}}
  {{- if (mustRegexMatch "[1-9][0-9]+" (toString $value)) -}}
    {{- $value | int -}}
  {{- else -}}
    {{- $value -}}
  {{- end -}}
{{- end -}}
