{{- define "homepage.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.homepageStorage.config.type }}
    datasetName: {{ .Values.homepageStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.homepageStorage.config.hostPath | default "" }}
    targetSelector:
      homepage:
        homepage:
          mountPath: /app/config
        01-permissions:
          mountPath: /mnt/directories/config
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homepage:
        homepage:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homepageStorage.additionalStorages }}
  {{ printf "homepage-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      homepage:
        homepage:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
