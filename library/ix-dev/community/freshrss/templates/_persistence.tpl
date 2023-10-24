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
      freshrss-cron:
        freshrss-cron:
          mountPath: /var/www/FreshRSS/data
  extensions:
    enabled: true
    type: {{ .Values.freshrssStorage.extensions.type }}
    datasetName: {{ .Values.freshrssStorage.extensions.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.extensions.hostPath | default "" }}
    targetSelector:
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/extensions
      freshrss:
        freshrss:
          mountPath: /var/www/FreshRSS/extensions
      freshrss-cron:
        freshrss-cron:
          mountPath: /var/www/FreshRSS/extensions
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
      freshrss-cron:
        freshrss-cron:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{/* Database */}}
  postgresdata:
    enabled: true
    type: {{ .Values.freshrssStorage.pgData.type }}
    datasetName: {{ .Values.freshrssStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.freshrssStorage.pgBackup.type }}
    datasetName: {{ .Values.freshrssStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.freshrssStorage.pgBackup.hostPath | default "" }}
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
