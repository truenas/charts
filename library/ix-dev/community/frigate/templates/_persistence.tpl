{{- define "frigate.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.frigateStorage.config.type }}
    datasetName: {{ .Values.frigateStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.frigateStorage.config.hostPath | default "" }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /config
        01-init:
          mountPath: /config
  media:
    enabled: true
    type: {{ .Values.frigateStorage.media.type }}
    datasetName: {{ .Values.frigateStorage.media.datasetName | default "" }}
    hostPath: {{ .Values.frigateStorage.media.hostPath | default "" }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /media
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      frigate:
        frigate:
          mountPath: /tmp
  cache:
    enabled: true
    type: emptyDir
    medium: Memory
    size: {{ printf "%vGi" .Values.frigateStorage.cache.size }}
    targetSelector:
      frigate:
        frigate:
          mountPath: /tmp/cache
  {{- range $idx, $storage := .Values.frigateStorage.additionalStorages }}
  {{ printf "frigate-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      frigate:
        frigate:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
