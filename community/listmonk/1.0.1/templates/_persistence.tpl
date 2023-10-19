{{- define "listmonk.persistence" -}}
persistence:
  uploads:
    enabled: true
    type: {{ .Values.listmonkStorage.uploads.type }}
    datasetName: {{ .Values.listmonkStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.listmonkStorage.uploads.hostPath | default "" }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /listmonk/uploads
        01-permissions:
          mountPath: /mnt/directories/uploads
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      listmonk:
        listmonk:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.listmonkStorage.additionalStorages }}
  {{ printf "listmonk-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      listmonk:
        listmonk:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}

  {{/* Database */}}
  postgresdata:
    enabled: true
    type: {{ .Values.listmonkStorage.pgData.type }}
    datasetName: {{ .Values.listmonkStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.listmonkStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Postgres - Permissions container
        # Different than the 01-permissions
        permissions:
          mountPath: /mnt/directories/postgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.listmonkStorage.pgBackup.type }}
    datasetName: {{ .Values.listmonkStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.listmonkStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Postgres - Permissions container
        # Different than the 01-permissions
        permissions:
          mountPath: /mnt/directories/postgres_backup
{{- end -}}
