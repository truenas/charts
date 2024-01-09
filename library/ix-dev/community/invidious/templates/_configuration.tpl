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
    {{- $hmacKey = ((index .data "HMAC_KEY") | b64dec) -}}
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
      HMAC_KEY: {{ $hmacKey }}
      INVIDIOUS_CONFIG: |
        hmac_key: {{ $hmacKey }}
        # Database
        check_tables: true
        db:
          user: {{ $dbUser }}
          password: {{ $dbPass }}
          dbname: {{ $dbName }}
          host: {{ $dbHost }}
          port: 5432

        # Network
        host_binding: 0.0.0.0
        port: {{ .Values.invidiousNetwork.webPort }}
{{- end -}}
