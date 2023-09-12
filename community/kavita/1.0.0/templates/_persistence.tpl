{{- define "kavita.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.kavitaStorage.config.type }}
    datasetName: {{ .Values.kavitaStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.kavitaStorage.config.hostPath | default "" }}
    targetSelector:
      kavita:
        kavita:
          mountPath: /kavita/config

  {{- range $idx, $storage := .Values.kavitaStorage.additionalStorages }}
  {{ printf "kavita-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      kavita:
        kavita:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
