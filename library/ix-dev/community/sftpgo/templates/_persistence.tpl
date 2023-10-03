{{- define "sftpgo.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.readarrStorage.config.type }}
    datasetName: {{ .Values.readarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.readarrStorage.config.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /var/lib/sftpgo
        01-permissions:
          mountPath: /mnt/directories/config
  data:
    enabled: true
    type: {{ .Values.readarrStorage.data.type }}
    datasetName: {{ .Values.readarrStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.readarrStorage.data.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/data
        01-permissions:
          mountPath: /mnt/directories/data
  backups:
    enabled: true
    type: {{ .Values.readarrStorage.backup.type }}
    datasetName: {{ .Values.readarrStorage.backup.datasetName | default "" }}
    hostPath: {{ .Values.readarrStorage.backup.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /srv/sftpgo/backups
        01-permissions:
          mountPath: /mnt/directories/backups
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.readarrStorage.additionalStorages }}
  {{ printf "sftpgo-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      sftpgo:
        sftpgo:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
