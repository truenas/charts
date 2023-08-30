{{- define "planka.persistence" -}}
persistence:
  avatars:
    enabled: true
    type: {{ .Values.plankaStorage.avatars.type }}
    datasetName: {{ .Values.plankaStorage.avatars.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.avatars.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/user-avatars
        01-permissions:
          mountPath: /mnt/directories/user-avatars
  bg-img:
    enabled: true
    type: {{ .Values.plankaStorage.backgroundImages.type }}
    datasetName: {{ .Values.plankaStorage.backgroundImages.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.backgroundImages.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/public/project-background-images
        01-permissions:
          mountPath: /mnt/directories/project-background-images
  attachments:
    enabled: true
    type: {{ .Values.plankaStorage.attachments.type }}
    datasetName: {{ .Values.plankaStorage.attachments.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.attachments.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: /app/private/attachments
        01-permissions:
          mountPath: /mnt/directories/attachments
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      planka:
        planka:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.plankaStorage.additionalStorages }}
  {{ printf "planka-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      planka:
        planka:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  {{/* Database */}}
  postgresdata:
    enabled: true
    type: {{ .Values.plankaStorage.pgData.type }}
    datasetName: {{ .Values.plankaStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.plankaStorage.pgBackup.type }}
    datasetName: {{ .Values.plankaStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.plankaStorage.pgBackup.hostPath | default "" }}
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
