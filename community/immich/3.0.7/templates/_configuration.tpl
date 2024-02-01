{{- define "immich.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "immich" -}}
  {{- $dbName := "immich" -}}

  {{- $dbPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "immichDbPass" $dbPass -}}
  {{- $_ := set .Values "immichDbHost" $dbHost -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}

  {{- $mlURL := printf "http://%v-machinelearning:%v" $fullname .Values.immichNetwork.machinelearningPort }}

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

  {{/* Server & Microservices */}}
  immich-creds:
    enabled: true
    data:
      IMMICH_MACHINE_LEARNING_ENABLED: {{ .Values.immichConfig.enableML | quote }}
      {{- if .Values.immichConfig.enableML }}
      IMMICH_MACHINE_LEARNING_URL: {{ $mlURL | quote }}
      {{- end }}
      DB_USERNAME: {{ $dbUser }}
      DB_PASSWORD: {{ $dbPass }}
      DB_HOSTNAME: {{ $dbHost }}
      DB_DATABASE_NAME: {{ $dbName }}
      DB_PORT: "5432"
      REDIS_HOSTNAME: {{ $redisHost }}
      REDIS_PASSWORD: {{ $redisPass }}
      REDIS_PORT: "6379"
      REDIS_DBINDEX: "0"

configmap:
  server-config:
    enabled: true
    data:
      LOG_LEVEL: log
      NODE_ENV: production
      SERVER_PORT: {{ .Values.immichNetwork.webuiPort | quote }}

  micro-config:
    enabled: true
    data:
      LOG_LEVEL: log
      NODE_ENV: production
      MICROSERVICES_PORT: {{ .Values.immichNetwork.microservicesPort | quote }}
      REVERSE_GEOCODING_DUMP_DIRECTORY: /microcache

  {{- if .Values.immichConfig.enableML }}
  ml-config:
    enabled: true
    data:
      NODE_ENV: production
      MACHINE_LEARNING_PORT: {{ .Values.immichNetwork.machinelearningPort | quote }}
      MACHINE_LEARNING_CACHE_FOLDER: /mlcache
      TRANSFORMERS_CACHE: /mlcache
  {{- end }}
{{- end -}}
