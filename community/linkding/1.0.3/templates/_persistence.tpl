{{- define "linkding.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.linkdingStorage.data.type }}
    datasetName: {{ .Values.linkdingStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.linkdingStorage.data.hostPath | default "" }}
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/data
        01-permissions:
          mountPath: /mnt/directories/data
  secret:
    enabled: true
    type: secret
    objectName: linkding-secret
    defaultMode: "0600"
    targetSelector:
      linkding:
        linkding:
          mountPath: /etc/linkding/secretkey.txt
          subPath: secretkey.txt
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      linkding:
        linkding:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.linkdingStorage.additionalStorages }}
  {{ printf "linkding-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      linkding:
        linkding:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  {{/* Database */}}
  postgresdata:
    enabled: true
    type: {{ .Values.linkdingStorage.pgData.type }}
    datasetName: {{ .Values.linkdingStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.linkdingStorage.pgData.hostPath | default "" }}
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
    type: {{ .Values.linkdingStorage.pgBackup.type }}
    datasetName: {{ .Values.linkdingStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.linkdingStorage.pgBackup.hostPath | default "" }}
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
