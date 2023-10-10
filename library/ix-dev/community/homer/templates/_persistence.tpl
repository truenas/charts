{{- define "homer.persistence" -}}
persistence:
  assets:
    enabled: true
    type: {{ .Values.homerStorage.assets.type }}
    datasetName: {{ .Values.homerStorage.assets.datasetName | default "" }}
    hostPath: {{ .Values.homerStorage.assets.hostPath | default "" }}
    targetSelector:
      homer:
        homer:
          mountPath: /www/assets
        01-permissions:
          mountPath: /mnt/directories/assets
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homer:
        homer:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homerStorage.additionalStorages }}
  {{ printf "homer-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      homer:
        homer:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
