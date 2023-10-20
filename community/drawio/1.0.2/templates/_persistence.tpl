{{- define "drawio.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      drawio:
        drawio:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.drawioStorage.additionalStorages }}
  {{ printf "drawio-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      drawio:
        drawio:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
