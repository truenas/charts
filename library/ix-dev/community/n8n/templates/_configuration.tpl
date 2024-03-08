{{- define "n8n.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "n8n" -}}
  {{- $dbName := "n8n" -}}

  {{- $dbPass := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "n8nDbPass" $dbPass -}}
  {{- $_ := set .Values "n8nDbHost" $dbHost -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $encKey := (randAlphaNum 32) -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-n8n-creds" $fullname)) -}}
    {{- $encKey = ((index .data "N8N_ENCRYPTION_KEY") | b64dec) -}}
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

  n8n-creds:
    enabled: true
    data:
      N8N_ENCRYPTION_KEY: {{ $encKey }}
      DB_TYPE: postgresdb
      EXECUTIONS_MODE: regular
      DB_POSTGRESDB_USER: {{ $dbUser }}
      DB_POSTGRESDB_PASSWORD: {{ $dbPass }}
      DB_POSTGRESDB_DATABASE: {{ $dbName }}
      DB_POSTGRESDB_HOST: {{ $dbHost }}
      DB_POSTGRESDB_PORT: "5432"
      QUEUE_BULL_REDIS_USERNAME: default
      QUEUE_BULL_REDIS_PASSWORD: {{ $redisPass }}
      QUEUE_BULL_REDIS_DB: "0"
      QUEUE_BULL_REDIS_HOST: {{ $redisHost }}
      QUEUE_BULL_REDIS_PORT: "6379"

{{- $prot := "http" -}}
{{- if .Values.n8nNetwork.certificateID -}}
  {{- $prot = "https" -}}
{{- end }}
configmap:
  n8n-config:
    enabled: true
    data:
      NODE_ENV: production
      N8N_PATH: /
      N8N_PORT: {{ .Values.n8nNetwork.webPort | quote }}
      N8N_HOST: {{ .Values.n8nConfig.webHost | quote }}
      GENERIC_TIMEZONE: {{ .Values.TZ }}
      N8N_SECURE_COOKIE: {{ ternary "true" "false" (eq $prot "https") | quote }}
      N8N_PROTOCOL: {{ $prot }}
      N8N_USER_FOLDER: "/data"
      {{- if .Values.n8nNetwork.certificateID }}
      N8N_SSL_KEY: /certs/tls.key
      N8N_SSL_CERT: /certs/tls.crt
      {{- end }}
{{- end -}}
