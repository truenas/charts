{{- define "joplin.persistence" -}}
persistence:
  postgresdata:
    enabled: true
    type: {{ .Values.joplinStorage.pgData.type }}
    datasetName: {{ .Values.joplinStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.joplinStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Postgres - Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.joplinStorage.pgBackup.type }}
    datasetName: {{ .Values.joplinStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.joplinStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Postgres - Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_backup
{{- end -}}
