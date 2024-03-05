{{- define "minio.configuration" -}}

  {{- $fullname := (include "ix.v1.common.lib.chart.names.fullname" $) -}}

  {{- $auditToken := randAlphaNum 32 -}}
  {{- $queryToken := randAlphaNum 32 -}}
  {{/* Fetch secrets from pre-migration secret */}}
  {{- with (lookup "v1" "Secret" .Release.Namespace "logsearchapi-details") -}}
    {{- $auditToken = ((index .data "auditToken") | b64dec) -}}
    {{- $queryToken = ((index .data "queryToken") | b64dec) -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-logsearch-creds" $fullname)) -}}
    {{- $auditToken = ((index .data "LOGSEARCH_AUDIT_AUTH_TOKEN") | b64dec) -}}
    {{- $queryToken = ((index .data "MINIO_LOG_QUERY_AUTH_TOKEN") | b64dec) -}}
  {{- end -}}
  {{- $queryURL := printf "http://%v-log:8080" $fullname -}}
  {{- $webhookURL := printf "http://%v-log:8080/api/ingest?token=%v" $fullname $auditToken -}}

{{/*

  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "home-assistant" -}}
  {{- $dbName := "home-assistant" -}}
  {{- $dbPass := (randAlphaNum 32) -}}
*/}}

  {{/* Fetch secrets from pre-migration secret */}}
{{/*
  {{- with (lookup "v1" "Secret" .Release.Namespace "db-details") -}}
    {{- $dbUser = ((index .data "db-user") | b64dec) -}}
    {{- $dbPass = ((index .data "db-password") | b64dec) -}}
*/}}

    {{/* Previous installs had a typo */}}
{{/*
    {{- $dbName = "homeassistance" -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbUser = ((index .data "POSTGRES_USER") | b64dec) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
    {{- $dbName = ((index .data "POSTGRES_DB") | b64dec) -}}
  {{- end -}}
*/}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
{{/*
  {{- $_ := set .Values "haDbPass" $dbPass -}}
  {{- $_ := set .Values "haDbHost" $dbHost -}}
  {{- $_ := set .Values "haDbName" $dbName -}}
  {{- $_ := set .Values "haDbUser" $dbUser -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) -}}
  {{- $haDBURL := (printf "postgresql://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
*/}}

secret:
  minio-creds:
    enabled: true
    data:
      MINIO_ROOT_USER: {{ .Values.minioConfig.accessKey | quote }}
      MINIO_ROOT_PASSWORD: {{ .Values.minioConfig.secretKey | quote }}

    {{ if and .Values.minioNetwork.certificateID .Values.minioConfig.domain }}
      MINIO_BROWSER_REDIRECT_URL: {{ printf "https://%s:%v" .Values.minioConfig.domain .Values.minioNetwork.consolePort }}
      MINIO_SERVER_URL: {{ printf "https://%s:%v" .Values.minioConfig.domain .Values.minioNetwork.apiPort }}
    {{ end }}

    {{ if .Values.minioConfig.logSearchApi }}
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $queryToken }}
      MINIO_LOG_QUERY_URL: {{ $queryURL }}
      {{/*
        We can put any ID we want here. Just make sure it's unique
        It can be rolled on each startup without problems, or can be set to a static one.
      */}}
      {{ $id := printf "ix-%v" (randAlphaNum 5) }}
      {{ printf "MINIO_AUDIT_WEBHOOK_ENDPOINT_%s: %s" $id $webhookURL }}
      {{ printf "MINIO_AUDIT_WEBHOOK_ENABLE_%s: %s" $id ("on" | quote) }}
    {{ end }}

  logsearch-creds:
    enabled: true
    data:
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $queryToken | quote }}
      LOGSEARCH_AUDIT_AUTH_TOKEN: {{ $auditToken | quote }}
      LOGSEARCH_PG_CONN_STR: "TODO:"
      LOGSEARCH_DISK_CAPACITY_GB: {{ .Values.minioConfig.logSearchDiskCapacityGB }}
{{/*
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
  {{- if eq (include "home-assistant.is-migration" $) "true" }}
  postgres-backup-creds:
    enabled: true
    annotations:
      helm.sh/hook: "pre-upgrade"
      helm.sh/hook-delete-policy: "hook-succeeded"
      helm.sh/hook-weight: "1"
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}-ha
      POSTGRES_URL: {{ printf "postgres://%s:%s@%s-ha:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName }}
  {{- end }}
*/}}
{{- end -}}
