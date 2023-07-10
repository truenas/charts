{{- define "autobrr.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.autobrrStorage.config.type }}
    datasetName: {{ .Values.autobrrStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.autobrrStorage.config.hostPath | default "" }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.autobrrStorage.additionalStorages }}
  {{ printf "autobrr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
