{{- define "deluge.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.delugeStorage.config.type }}
    datasetName: {{ .Values.delugeStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.config.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /config
        config:
          mountPath: /config
  downloads:
    enabled: true
    type: {{ .Values.delugeStorage.downloads.type }}
    datasetName: {{ .Values.delugeStorage.downloads.datasetName | default "" }}
    hostPath: {{ .Values.delugeStorage.downloads.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: /downloads
  {{- range $idx, $storage := .Values.delugeStorage.additionalStorages }}
  {{ printf "deluge-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      deluge:
        deluge:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
