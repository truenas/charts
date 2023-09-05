{{- define "rust.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.rustStorage.data.type }}
    datasetName: {{ .Values.rustStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.rustStorage.data.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: /root
      relay:
        relay:
          mountPath: /root
        01-permissions:
          mountPath: /mnt/directories/data
  {{- range $idx, $storage := .Values.rustStorage.additionalStorages }}
  {{ printf "rust-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      server:
        server:
          mountPath: {{ $storage.mountPath }}
      relay:
        relay:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
