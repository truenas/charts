{{- define "filebrowser.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.filebrowserStorage.config.type }}
    datasetName: {{ .Values.filebrowserStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.filebrowserStorage.config.hostPath | default "" }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: /config
        01-permissions:
          mountPath: /mnt/directories/config
  # tmp:
  #   enabled: true
  #   type: emptyDir
  #   targetSelector:
  #     lidarr:
  #       lidarr:
  #         mountPath: /tmp
  {{- range $idx, $storage := .Values.filebrowserStorage.additionalStorages }}
  {{ printf "filebrowser-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
