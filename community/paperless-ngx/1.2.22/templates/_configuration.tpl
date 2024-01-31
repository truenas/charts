{{- define "paperless.configuration" -}}
  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "paperless" -}}
  {{- $dbName := "paperless" -}}

  {{- $dbPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "paperlessDbPass" $dbPass -}}
  {{- $_ := set .Values "paperlessDbHost" $dbHost -}}

  {{- $redisHost := (printf "%s-redis" $fullname) -}}

  {{- $redisPass := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-redis-creds" $fullname)) -}}
    {{- $redisPass = ((index .data "REDIS_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}

  {{- $secretKey := randAlphaNum 32 -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-paperless-creds" $fullname)) -}}
    {{- $secretKey = ((index .data "PAPERLESS_SECRET_KEY") | b64dec) -}}
  {{- end }}

configmap:
  paperless-config:
    enabled: true
    data:
      PAPERLESS_TIME_ZONE: {{ .Values.TZ }}
      PAPERLESS_BIND_ADDR: "0.0.0.0"
      PAPERLESS_PORT: {{ .Values.paperlessNetwork.webPort | quote }}
      USERMAP_UID: {{ .Values.paperlessID.user | quote }}
      USERMAP_GID: {{ .Values.paperlessID.group | quote }}
      PAPERLESS_DATA_DIR: /usr/src/paperless/data
      PAPERLESS_MEDIA_ROOT: /usr/src/paperless/media
      PAPERLESS_CONSUMPTION_DIR: /usr/src/paperless/consume
      PAPERLESS_TRASH_DIR: {{ ternary "/usr/src/paperless/trash" nil .Values.paperlessConfig.enableTrash }}

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

  paperless-creds:
    enabled: true
    data:
      PAPERLESS_SECRET_KEY: {{ $secretKey }}
      PAPERLESS_ADMIN_USER: {{ .Values.paperlessConfig.adminUser | quote }}
      PAPERLESS_ADMIN_MAIL: {{ .Values.paperlessConfig.adminMail | quote }}
      PAPERLESS_ADMIN_PASSWORD: {{ .Values.paperlessConfig.adminPassword | quote }}
      PAPERLESS_DBENGINE: postgresql
      PAPERLESS_DBHOST: {{ $dbHost }}
      PAPERLESS_DBPORT: "5432"
      PAPERLESS_DBNAME: {{ $dbName }}
      PAPERLESS_DBUSER: {{ $dbUser }}
      PAPERLESS_DBPASS: {{ $dbPass }}
      PAPERLESS_REDIS:  {{ printf "redis://default:%s@%s:6379" $redisPass $redisHost }}
{{- end -}}
