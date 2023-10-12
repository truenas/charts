{{- define "searxng.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.searxngStorage.config.type }}
    datasetName: {{ .Values.searxngStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.searxngStorage.config.hostPath | default "" }}
    targetSelector:
      searxng:
        searxng:
          mountPath: /etc/searxng
        01-permissions:
          mountPath: /mnt/directories/searxng
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      searxng:
        searxng:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.searxngStorage.additionalStorages }}
  {{ printf "searxng-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      searxng:
        searxng:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
