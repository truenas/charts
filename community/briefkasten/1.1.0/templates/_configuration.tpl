{{- define "briefkasten.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $secretKey := randAlphaNum 64 -}}
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
  {{- $_ := set .Values "briefkastenDbHost" $dbHost -}}

  {{- $smtp := .Values.briefkastenConfig.smtp -}}
  {{- $github := .Values.briefkastenConfig.github -}}
  {{- $google := .Values.briefkastenConfig.google -}}
  {{- $keycloak := .Values.briefkastenConfig.keycloak -}}
  {{- $authentik := .Values.briefkastenConfig.authentik }}
secret:
  briefkasten:
    enabled: true
    data:
      NEXTAUTH_SECRET: {{ $secretKey }}
      DATABASE_URL: {{ $dbURL }}
      {{- if $smtp.enabled }}
      SMTP_SERVER: {{ $smtp.server }}
      SMTP_FROM: {{ $smtp.from }}
      {{- end -}}
      {{- if $github.enabled }}
      GITHUB_ID: {{ $github.id }}
      GITHUB_SECRET: {{ $github.secret }}
      {{- end -}}
      {{- if $google.enabled }}
      GOOGLE_ID: {{ $google.id }}
      GOOGLE_SECRET: {{ $google.secret }}
      {{- end -}}
      {{- if $keycloak.enabled }}
      KEYCLOAK_NAME: {{ $keycloak.name }}
      KEYCLOAK_ID: {{ $keycloak.id }}
      KEYCLOAK_SECRET: {{ $keycloak.secret }}
      KEYCLOAK_ISSUER: {{ $keycloak.issuer }}
      {{- end -}}
      {{- if $authentik.enabled }}
      AUTHENTIK_NAME: {{ $authentik.name }}
      AUTHENTIK_ID: {{ $authentik.id }}
      AUTHENTIK_SECRET: {{ $authentik.secret }}
      AUTHENTIK_ISSUER: {{ $authentik.issuer }}
      {{- end }}

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
      NEXTAUTH_URL_INTERNAL: http://127.0.0.1:{{ .Values.briefkastenNetwork.webPort }}
      PORT: {{ .Values.briefkastenNetwork.webPort | quote }}
      NODE_ENV: production
{{- end -}}
