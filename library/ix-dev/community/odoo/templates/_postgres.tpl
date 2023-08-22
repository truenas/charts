{{- define "postgres.workload" -}}
workload:
{{- include "ix.v1.common.app.postgres" (dict "secretName" "postgres-creds"
                                              "resources" .Values.resources
                                              "ixChartContext" .Values.ixChartContext) | nindent 2 }}

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
    type: {{ .Values.odooStorage.pgData.type }}
    datasetName: {{ .Values.odooStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.odooStorage.pgBackup.type }}
    datasetName: {{ .Values.odooStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.odooStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_backup
{{- end -}}
