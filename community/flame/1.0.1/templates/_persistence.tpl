{{- define "flame.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.flameStorage.data.type }}
    datasetName: {{ .Values.flameStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.flameStorage.data.hostPath | default "" }}
    targetSelector:
      flame:
        flame:
          mountPath: /app/data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      flame:
        flame:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.flameStorage.additionalStorages }}
  {{ printf "flame-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      flame:
        flame:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
