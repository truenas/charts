{{- define "briefkasten.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $secretKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-briefkasten" $fullname)) -}}
    {{- $secretKey = ((index .data "NEXTAUTH_SECRET") | b64dec) -}}
  {{- end -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "briefkasten" -}}
  {{- $dbName := "briefkasten" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "briefkastenDbPass" $dbPass -}}
  {{- $_ := set .Values "briefkastenDbHost" $dbHost }}

secret:
  briefkasten:
    enabled: true
    data:
      NEXTAUTH_SECRET: {{ $secretKey }}
      DATABASE_URL: {{ printf "postgresql://%s" $dbURL }}

  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

configmap:
  briefkasten:
    enabled: true
    data:
      NEXTAUTH_URL: {{ .Values.briefkastenConfig.url }}
      PORT: {{ .Values.briefkastenNetwork.webPort }}
      NODE_ENV: production
{{- end -}}
