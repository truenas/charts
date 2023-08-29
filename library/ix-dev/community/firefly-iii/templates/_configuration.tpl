{{- define "firefly.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "firefly" -}}
  {{- $dbName := "firefly" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "fireflyDbPass" $dbPass -}}
  {{- $_ := set .Values "fireflyDbHost" $dbHost -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $appKey := (randAlphaNum 32) -}}
  {{- $cronToken := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-firefly-config" $fullname)) -}}
    {{- $appKey = ((index .data "APP_KEY") | b64dec) -}}
    {{- $cronToken = ((index .data "STATIC_CRON_TOKEN") | b64dec) -}}
  {{- end -}}

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

  redis-creds:
    enabled: true
    data:
      ALLOW_EMPTY_PASSWORD: "no"
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_HOST: {{ $redisHost }}

  firefly-config:
    enabled: true
    data:
      DB_CONNECTION: pgsql
      DB_HOST: {{ $dbHost }}
      DB_PORT: "5432"
      DB_DATABASE: {{ $dbName }}
      DB_USERNAME: {{ $dbUser }}
      DB_PASSWORD: {{ $dbPass }}
      CACHE_DRIVER: redis
      SESSION_DRIVER: redis
      REDIS_HOST: {{ $redisHost }}
      REDIS_PORT: "6379"
      REDIS_USERNAME: default
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_DB: "0"
      REDIS_CACHE_DB: "1"
      APP_URL: {{ .Values.fireflyConfig.appUrl | trimSuffix "/" }}
      APP_KEY: {{ $appKey }}
      STATIC_CRON_TOKEN: {{ $cronToken }}

  importer-config:
    enabled: {{ .Values.fireflyConfig.enableImporter }}
    data:
      FIREFLY_III_URL: http://{{ $fullname }}:{{ .Values.fireflyNetwork.webPort }}
      EXPECT_SECURE_URL: "false"
      VANITY_URL: {{ .Values.fireflyConfig.appUrl | trimSuffix "/" }}
{{- end -}}
