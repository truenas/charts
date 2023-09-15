{{- define "cloudflared.persistence" -}}
persistence:
  {{- range $idx, $storage := .Values.cloudflaredStorage.additionalStorages }}
  {{ printf "cloudflared-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      cloudflared:
        cloudflared:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
