{{- define "immich.persistence" -}}
persistence:
  library:
    enabled: true
    type: {{ .Values.immichStorage.library.type }}
    datasetName: {{ .Values.immichStorage.library.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.library.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/library
        01-permissions:
          mountPath: /mnt/directories/library
  uploads:
    enabled: true
    type: {{ .Values.immichStorage.uploads.type }}
    datasetName: {{ .Values.immichStorage.uploads.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.uploads.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/upload
        01-permissions:
          mountPath: /mnt/directories/uploads
  thumbs:
    enabled: true
    type: {{ .Values.immichStorage.thumbs.type }}
    datasetName: {{ .Values.immichStorage.thumbs.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.thumbs.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/thumbs
        01-permissions:
          mountPath: /mnt/directories/thumbs
  profile:
    enabled: true
    type: {{ .Values.immichStorage.profile.type }}
    datasetName: {{ .Values.immichStorage.profile.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.profile.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/profile
        01-permissions:
          mountPath: /mnt/directories/profile
  video:
    enabled: true
    type: {{ .Values.immichStorage.video.type }}
    datasetName: {{ .Values.immichStorage.video.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.video.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /usr/src/app/upload/encoded-video
        01-permissions:
          mountPath: /mnt/directories/video

  postgresdata:
    enabled: true
    type: {{ .Values.immichStorage.pgData.type }}
    datasetName: {{ .Values.immichStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.immichStorage.pgBackup.type }}
    datasetName: {{ .Values.immichStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.immichStorage.pgBackup.hostPath | default "" }}
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
