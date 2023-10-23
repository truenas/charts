{{- define "planka.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $secretKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-planka" $fullname)) -}}
    {{- $secretKey = ((index .data "SECRET_KEY") | b64dec) -}}
  {{- end -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "planka" -}}
  {{- $dbName := "planka" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "plankaDbPass" $dbPass -}}
  {{- $_ := set .Values "plankaDbHost" $dbHost }}

secret:
  planka:
    enabled: true
    data:
      SECRET_KEY: {{ $secretKey }}
      DATABASE_URL: {{ printf "postgresql://%s" $dbURL }}
      {{- if .Values.plankaConfig.defaultAdminEmail }}
      DEFAULT_ADMIN_EMAIL: {{ .Values.plankaConfig.defaultAdminEmail }}
      DEFAULT_ADMIN_PASSWORD: {{ .Values.plankaConfig.defaultAdminPassword }}
      DEFAULT_ADMIN_NAME: {{ .Values.plankaConfig.defaultAdminName }}
      DEFAULT_ADMIN_USERNAME: {{ .Values.plankaConfig.defaultAdminUsername }}
      {{- end }}

  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ printf "postgres://%s" $dbURL }}

{{- if and
        (not (hasPrefix "http://" .Values.plankaConfig.baseURL))
        (not (hasPrefix "https://" .Values.plankaConfig.baseURL)) -}}
  {{- fail "Planka - Expected [Base URL] to start with [http://] or [https://]" -}}
{{- end }}

configmap:
  planka:
    enabled: true
    data:
      NODE_ENV: production
      BASE_URL: {{ .Values.plankaConfig.baseURL }}
      TRUST_PROXY: {{ ternary "1" "0" .Values.plankaConfig.trustProxy | quote }}
{{- end -}}
