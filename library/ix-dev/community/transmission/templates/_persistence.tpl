{{- define "transmission.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.transmissionStorage.config.type }}
    datasetName: {{ .Values.transmissionStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.transmissionStorage.config.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  downloads:
    enabled: true
    type: {{ .Values.transmissionStorage.downloads.type }}
    datasetName: {{ .Values.transmissionStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.transmissionStorage.downloads.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: /downloads
        01-permissions:
          mountPath: /mnt/directories/downloads
  {{- range $idx, $storage := .Values.transmissionStorage.additionalStorages }}
  {{ printf "transmission-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      transmission:
        transmission:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
