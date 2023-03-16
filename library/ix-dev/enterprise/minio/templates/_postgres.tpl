{{- define "postgres.workload" -}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds" "resources" .Values.resources) | nindent 2 }}

{{/* Service */}}
service:
  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetSelector: postgres

{{/* Persistence */}}
persistence:
  postgresdata:
    enabled: true
    type: {{ .Values.minioLogging.logsearch.pgData.type }}
    datasetName: {{ .Values.minioLogging.logsearch.pgData.datasetName | default "" }}
    hostPath: {{ .Values.minioLogging.logsearch.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Permissions container
        permissions:
          mountPath: /mnt/directories/posgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.minioLogging.logsearch.pgBackup.type }}
    datasetName: {{ .Values.minioLogging.logsearch.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.minioLogging.logsearch.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Permissions container
        permissions:
          mountPath: /mnt/directories/posgres_backup
{{- end -}}
