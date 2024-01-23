{{- define "homarr.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $secretKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-homarr-creds" $fullname)) -}}
    {{- $secretKey = ((index .data "NEXTAUTH_SECRET") | b64dec) -}}
  {{- end }}

secret:
  homarr-creds:
    enabled: true
    data:
      NEXTAUTH_SECRET: {{ $secretKey }}
{{- end -}}
