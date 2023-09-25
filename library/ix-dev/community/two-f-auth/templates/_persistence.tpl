{{- define "twofauth.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.twofauthStorage.config.type }}
    datasetName: {{ .Values.twofauthStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.twofauthStorage.config.hostPath | default "" }}
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /2fauth
        01-permissions:
          mountPath: /mnt/directories/2fauth
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      twofauth:
        twofauth:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.twofauthStorage.additionalStorages }}
  {{ printf "twofauth-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      twofauth:
        twofauth:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
{{- end -}}
