{{- define "paperless.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.paperlessStorage.data.type }}
    datasetName: {{ .Values.paperlessStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.data.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/data
  media:
    enabled: true
    type: {{ .Values.paperlessStorage.media.type }}
    datasetName: {{ .Values.paperlessStorage.media.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.media.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/media
  consume:
    enabled: true
    type: {{ .Values.paperlessStorage.consume.type }}
    datasetName: {{ .Values.paperlessStorage.consume.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.consume.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/consume
  trash:
    enabled: true
    type: {{ .Values.paperlessStorage.trash.type }}
    datasetName: {{ .Values.paperlessStorage.trash.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.trash.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/trash
        01-permissions:
          mountPath: /mnt/directories/trash
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      paperless:
        paperless:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.paperlessStorage.additionalStorages }}
  {{ printf "paperless-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      paperless:
        paperless:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  postgresdata:
    enabled: true
    type: {{ .Values.paperlessStorage.pgData.type }}
    datasetName: {{ .Values.paperlessStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.paperlessStorage.pgBackup.type }}
    datasetName: {{ .Values.paperlessStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.paperlessStorage.pgBackup.hostPath | default "" }}
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
