{{- define "wgeasy.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.wgStorage.config.type }}
    datasetName: {{ .Values.wgStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.wgStorage.config.hostPath | default "" }}
    targetSelector:
      wgeasy:
        wgeasy:
          mountPath: /etc/wireguard
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      wgeasy:
        wgeasy:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.wgStorage.additionalStorages }}
  {{ printf "wgeasy-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      wgeasy:
        wgeasy:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
