{{- define "freshrss.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.freshrssStorage.data.type }}
    datasetName: {{ .Values.freshrssStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.data.hostPath | default "" }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/data
        01-permissions:
          mountPath: /mnt/directories/data
  extensions:
    enabled: true
    type: {{ .Values.freshrssStorage.extensions.type }}
    datasetName: {{ .Values.freshrssStorage.extensions.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.extensions.hostPath | default "" }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/extensions
        01-permissions:
          mountPath: /mnt/directories/extensions
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.freshrssStorage.additionalStorages }}
  {{ printf "freshrss-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  {{/* Database */}}
  postgresdata:
    enabled: true
    type: {{ .Values.briefkastenStorage.pgData.type }}
    datasetName: {{ .Values.briefkastenStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.briefkastenStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.briefkastenStorage.pgBackup.type }}
    datasetName: {{ .Values.briefkastenStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.briefkastenStorage.pgBackup.hostPath | default "" }}
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
