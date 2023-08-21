{{- define "readarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.readarrStorage.config.type }}
    datasetName: {{ .Values.readarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.readarrStorage.config.hostPath | default "" }}
    targetSelector:
      readarr:
        readarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      readarr:
        readarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.readarrStorage.additionalStorages }}
  {{ printf "readarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      readarr:
        readarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
