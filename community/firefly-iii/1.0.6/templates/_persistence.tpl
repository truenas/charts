{{- define "firefly.persistence" -}}
persistence:
  uploads:
    enabled: true
    type: {{ .Values.fireflyStorage.uploads.type }}
    datasetName: {{ .Values.fireflyStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.fireflyStorage.uploads.hostPath | default "" }}
    targetSelector:
      firefly:
        firefly:
          mountPath: /var/www/html/storage/upload
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      firefly:
        firefly:
          mountPath: /tmp
      firefly-importer:
        firefly-importer:
          mountPath: /tmp

  # Postgres
  postgresdata:
    enabled: true
    type: {{ .Values.fireflyStorage.pgData.type }}
    datasetName: {{ .Values.fireflyStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.fireflyStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.fireflyStorage.pgBackup.type }}
    datasetName: {{ .Values.fireflyStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.fireflyStorage.pgBackup.hostPath | default "" }}
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
