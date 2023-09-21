{{- define "briefkasten.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.briefkastenStorage.additionalStorages }}
  {{ printf "briefkasten-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      briefkasten:
        briefkasten:
          mountPath: {{ $storage.mountPath }}
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
