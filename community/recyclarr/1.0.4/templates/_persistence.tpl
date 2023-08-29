{{- define "recyclarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.recyclarrStorage.config.type }}
    datasetName: {{ .Values.recyclarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.recyclarrStorage.config.hostPath | default "" }}
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.recyclarrStorage.additionalStorages }}
  {{ printf "recyclarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      recyclarr:
        recyclarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
