{{- define "twofauth.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $appKey := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-twofauth-creds" $fullname)) -}}
    {{- $appKey = ((index .data "APP_KEY") | b64dec) -}}
  {{- end }}

secret:
  twofauth-creds:
    enabled: true
    data:
      APP_KEY: {{ $appKey }}

configmap:
  twofauth-config:
    enabled: true
    data:
      APP_ENV: production
      APP_NAME: {{ .Values.twofauthConfig.appName }}
      APP_URL: {{ .Values.twofauthConfig.appUrl }}
      DB_DATABASE: /2fauth/db/database.sqlite
{{- end -}}
