{{- define "whoogle.persistence" -}}
persistence:
  # config:
  #   enabled: true
  #   type: {{ .Values.whoogleStorage.config.type }}
  #   datasetName: {{ .Values.whoogleStorage.config.datasetName | default "" }}
  #   hostPath: {{ .Values.whoogleStorage.config.hostPath | default "" }}
  #   targetSelector:
  #     whoogle:
  #       whoogle:
  #         mountPath: /config
  #       01-permissions:
  #         mountPath: /mnt/directories/config
  config:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /tmp
  runtor:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /run/tor
  varlibtor:
    enabled: true
    type: emptyDir
    targetSelector:
      whoogle:
        whoogle:
          mountPath: /var/lib/tor
        01-permissions:
          mountPath: /mnt/directories/varlibtor
  {{- range $idx, $storage := .Values.whoogleStorage.additionalStorages }}
  {{ printf "whoogle-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      whoogle:
        whoogle:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
