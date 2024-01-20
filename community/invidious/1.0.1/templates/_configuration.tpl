{{- define "invidious.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "kemal" -}} {{/* User is hardcoded */}}
  {{- $dbName := "invidious" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $hmacKey := (randAlphaNum 64) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-invidious-creds" $fullname)) -}}
    {{- $hmacKey = ((index .data "INVIDIOUS_HMAC_KEY") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "invidiousDbPass" $dbPass -}}
  {{- $_ := set .Values "invidiousDbHost" $dbHost -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
      # Used by invidious init script
      PGPASSWORD: {{ $dbPass }}
      PGHOST: {{ $dbHost }}
      PGPORT: "5432"


  invidious-creds:
    enabled: true
    data:
      # Source config
      INVIDIOUS_CONFIG_FILE: /config/config.yaml
      # See https://github.com/iv-org/invidious/pull/1702
      # Override config
      INVIDIOUS_HMAC_KEY: {{ $hmacKey }}
      INVIDIOUS_CHECK_TABLES: "true"
      INVIDIOUS_DATABASE_URL: {{ $dbURL }}
      INVIDIOUS_DB_USER: {{ $dbUser }}
      INVIDIOUS_DB_PASSWORD: {{ $dbPass }}
      INVIDIOUS_DB_DBNAME: {{ $dbName }}
      INVIDIOUS_DB_HOST: {{ $dbHost }}
      INVIDIOUS_DB_PORT: "5432"
      INVIDIOUS_HOST_BINDING: "0.0.0.0"
      INVIDIOUS_PORT: {{ .Values.invidiousNetwork.webPort | quote }}
      # Add some easy to use values in UI
      INVIDIOUS_ADMINS: {{ .Values.invidiousConfig.admins | toJson | quote }}
      INVIDIOUS_REGISTRATION_ENABLED: {{ .Values.invidiousConfig.registrationEnabled | quote }}
      INVIDIOUS_LOGIN_ENABLED: {{ .Values.invidiousConfig.loginEnabled | quote }}
      INVIDIOUS_CAPTCHA_ENABLED: {{ .Values.invidiousConfig.captchaEnabled | quote }}
{{- end -}}
