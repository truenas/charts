{{- define "bazarr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.bazarrStorage.config.type }}
    datasetName: {{ .Values.bazarrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.bazarrStorage.config.hostPath | default "" }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.bazarrStorage.additionalStorages }}
  {{ printf "bazarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
