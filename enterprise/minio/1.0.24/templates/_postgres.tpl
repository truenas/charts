{{- define "postgres.workload" -}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds" "resources" .Values.resources) | nindent 2 }}

{{/* Service */}}
service:
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{/* Persistence */}}
persistence:
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.minioLogging.logsearch.pgData
            "pgBackup" .Values.minioLogging.logsearch.pgBackup
      ) | nindent 2 }}
{{- end -}}
