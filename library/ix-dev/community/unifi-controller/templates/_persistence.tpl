{{- define "unifi.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.unifiStorage.data.type }}
    datasetName: {{ .Values.unifiStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.unifiStorage.data.hostPath | default "" }}
    targetSelector:
      unifi:
        unifi:
          mountPath: /unifi
        01-permissions:
          mountPath: /mnt/directories/unifi
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      unifi:
        unifi:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.unifiStorage.additionalStorages }}
  {{ printf "unifi-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      unifi:
        unifi:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
