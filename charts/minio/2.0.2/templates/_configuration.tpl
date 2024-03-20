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

  {{/* DB details */}}
  {{- $dbHost := (printf "%s-postgres" $fullname) -}}
  {{- $dbUser := "logsearchapi" -}}
  {{- $dbName := "logsearchapi" -}}
  {{- $dbPass := randAlphaNum 32 -}}

  {{/* Fetch secrets from pre-migration secret */}}
  {{- $tmpBackupHost := "" -}}
  {{- with (lookup "v1" "Secret" .Release.Namespace "postgres-details") -}}
    {{- $dbPass = ((index .data "db_password") | b64dec) -}}
    {{- $tmpBackupHost = ((index .data "postgresHost") | b64dec) -}}
  {{- end -}}

  {{- with (lookup "v1" "Secret" .Release.Namespace (printf "%s-postgres-creds" $fullname)) -}}
    {{- $dbPass = ((index .data "POSTGRES_PASSWORD") | b64dec) -}}
  {{- end -}}

  {{/* Temporary set dynamic db details on values,
  so we can print them on the notes */}}
  {{- $_ := set .Values "minioDbPass" $dbPass -}}
  {{- $_ := set .Values "minioDbHost" $dbHost -}}

  {{- $dbURL := (printf "postgres://%s:%s@%s:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName) }}
secret:
  minio-creds:
    enabled: true
    data:
      MINIO_ROOT_USER: {{ .Values.minioConfig.rootUser | quote }}
      MINIO_ROOT_PASSWORD: {{ .Values.minioConfig.rootPassword | quote }}

    {{ if and .Values.minioNetwork.certificateID .Values.minioConfig.domain }}
      MINIO_BROWSER_REDIRECT_URL: {{ printf "https://%s:%v" .Values.minioConfig.domain .Values.minioNetwork.consolePort }}
      MINIO_SERVER_URL: {{ printf "https://%s:%v" .Values.minioConfig.domain .Values.minioNetwork.apiPort }}
    {{ end }}

    {{ if .Values.minioStorage.logSearchApi }}
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $queryToken }}
      MINIO_LOG_QUERY_URL: {{ $queryURL }}
      MINIO_AUDIT_WEBHOOK_ENDPOINT_ix-logsearch: {{ $webhookURL }}
      MINIO_AUDIT_WEBHOOK_ENABLE_ix-logsearch: "on"
    {{ end }}

  logsearch-creds:
    enabled: true
    data:
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $queryToken | quote }}
      LOGSEARCH_AUDIT_AUTH_TOKEN: {{ $auditToken | quote }}
      LOGSEARCH_PG_CONN_STR: {{ $dbURL | quote }}
      LOGSEARCH_DISK_CAPACITY_GB: {{ .Values.minioStorage.logSearchDiskCapacityGB | quote }}
  postgres-creds:
    enabled: true
    data:
      POSTGRES_USER: {{ $dbUser }}
      POSTGRES_DB: {{ $dbName }}
      POSTGRES_PASSWORD: {{ $dbPass }}
      POSTGRES_HOST: {{ $dbHost }}
      POSTGRES_URL: {{ $dbURL }}
  {{- if eq (include "minio.is-migration" $) "true" }}
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
      POSTGRES_HOST: {{ $tmpBackupHost }}
      POSTGRES_URL: {{ printf "postgres://%s:%s@%s-pg:5432/%s?sslmode=disable" $dbUser $dbPass $dbHost $dbName }}
  {{- end }}
{{- end -}}
