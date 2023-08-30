{{- define "homarr.persistence" -}}
persistence:
  configs:
    enabled: true
    type: {{ .Values.homarrStorage.configs.type }}
    datasetName: {{ .Values.homarrStorage.configs.datasetName | default "" }}
    hostPath: {{ .Values.homarrStorage.configs.hostPath | default "" }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/data/configs
        01-permissions:
          mountPath: /mnt/directories/configs
  icons:
    enabled: true
    type: {{ .Values.homarrStorage.icons.type }}
    datasetName: {{ .Values.homarrStorage.icons.datasetName | default "" }}
    hostPath: {{ .Values.homarrStorage.icons.hostPath | default "" }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/data/icons
        01-permissions:
          mountPath: /mnt/directories/icons
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      homarr:
        homarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.homarrStorage.additionalStorages }}
  {{ printf "homarr-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      homarr:
        homarr:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
