{{- define "immich.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "immich" -}}
  {{- $dbName := "immich" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{ $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}

  immich-creds:
    enabled: true
    data:
      DB_USERNAME: {{ $dbUser }}
      DB_PASSWORD: {{ $dbPass }}
      DB_HOSTNAME: {{ $dbHost }}
      DB_DATABASE_NAME: {{ $dbName }}
      DB_PORT: "5432"
      # TODO: Redis
      # REDIS_HOSTNAME:
      # REDIS_PASSWORD:
      # REDIS_PORT: "6379"
      # REDIS_DBINDEX: "0"
configmap:
  server-config:
    enabled: true
    data:
      SERVER_PORT: {{ .Values.immichNetwork.serverPort | quote }}
      ENABLE_MAPBOX: {{ .Values.immichConfig.enableMapbox | quote }}
      DISABLE_REVERSE_GEOCODING: {{ .Values.immichConfig.disableReverseGeocoding | quote }}
      {{- if not .Values.immichConfig.disableReverseGeocoding }}
      REVERSE_GEOCODING_PRECISION: {{ .Values.immichConfig.reverseGeocodingPrecision | quote }}
      {{- end }}

  web-config:
    enabled: true
    data:
      PORT: {{ .Values.immichNetwork.webPort | quote }}
{{- end -}}
