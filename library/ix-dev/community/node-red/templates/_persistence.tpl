{{- define "nodered.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.noderedStorage.data.type }}
    datasetName: {{ .Values.noderedStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.noderedStorage.data.hostPath | default "" }}
    targetSelector:
      nodered:
        nodered:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      nodered:
        nodered:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.noderedStorage.additionalStorages }}
  {{ printf "nodered-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      nodered:
        nodered:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
