{{- define "postgres.workload" -}}
{{/* Postgres Database */}}
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
    type: {{ .Values.vaultwardenStorage.pgData.type }}
    datasetName: {{ .Values.vaultwardenStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.vaultwardenStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Permissions container, for postgres, container is named "permissions"
        permissions:
          mountPath: /mnt/directories/postgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.vaultwardenStorage.pgBackup.type }}
    datasetName: {{ .Values.vaultwardenStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.vaultwardenStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Permissions container, for postgres, container is named "permissions"
        permissions:
          mountPath: /mnt/directories/postgres_backup
{{- end -}}
