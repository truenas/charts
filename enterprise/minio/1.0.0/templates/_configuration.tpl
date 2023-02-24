{{- define "minio.configuration" -}}

  {{/* Validation */}}
  {{ (include "minio.validation" $) }}

  {{ $config := fromJson (include "minio.prepare.config" $) }}

configmap:
  minio-config:
    enabled: true
    data:
      MINIO_VOLUMES: {{ $config.volumes }}
      {{ with .Values.minio.network.server_url }}
      MINIO_SERVER_URL: {{ . | quote }}
      {{ end }}
      {{ with .Values.minio.network.console_url }}
      MINIO_BROWSER_REDIRECT_URL: {{ . | quote }}
      {{ end }}

  {{ if .Values.logsearch.enabled }}
  logsearch-config:
    enabled: true
    data:
      LOGSEARCH_DISK_CAPACITY_GB: {{ $config.diskCapacity | quote }}

  postgres-config:
    enabled: true
    data:
      POSTGRES_USER: {{ $config.dbUser }}
      POSTGRES_DB: {{ $config.dbName }}
      POSTGRES_HOST: {{ $config.dbHost }}
      POSTGRES_URL: {{ $config.postgresURL }}
  {{ end }}

secret:
  minio-creds:
    enabled: true
    data:
      MINIO_ROOT_USER: {{ .Values.minio.creds.root_user }}
      MINIO_ROOT_PASSWORD: {{ .Values.minio.creds.root_pass }}
      {{ if .Values.logsearch.enabled }}
      MINIO_AUDIT_WEBHOOK_ENABLE_ix_logsearch: "on"
      MINIO_AUDIT_WEBHOOK_ENDPOINT_ix_logsearch: {{ $config.webhookURL }}
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $config.queryToken }}
      MINIO_LOG_QUERY_URL: {{ $config.logQueryURL }}
      {{ end }}

  {{ if .Values.logsearch.enabled }}
  logsearch-creds:
    enabled: true
    data:
      LOGSEARCH_PG_CONN_STR: {{ $config.postgresURL }}
      LOGSEARCH_AUDIT_AUTH_TOKEN: {{ $config.auditToken }}
      MINIO_LOG_QUERY_AUTH_TOKEN: {{ $config.queryToken }}

  postgres-creds:
    enabled: true
    data:
      POSTGRES_PASSWORD: {{ $config.dbPass }}
  {{ end }}

{{/* MinIO Certificate */}}
{{ if .Values.minio.network.certificate_id }}
scaleCertificate:
  minio-cert:
    enabled: true
    labels: {}
    annotations: {}
    id: {{ .Values.minio.network.certificate_id }}
{{ end }}

{{- end -}}
