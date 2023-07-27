{{- define "tmm.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.tmmStorage.data.type }}
    datasetName: {{ .Values.tmmStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.tmmStorage.data.hostPath | default "" }}
    targetSelector:
      tmm:
        tmm:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      tmm:
        tmm:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.tmmStorage.additionalStorages }}
  {{ printf "tmm-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      tmm:
        tmm:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
