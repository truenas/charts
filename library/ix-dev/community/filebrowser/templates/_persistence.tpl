{{- define "filebrowser.persistence" -}}
{{- $configBasePath := "/config" }}
persistence:
  config:
    enabled: true
    type: {{ .Values.filebrowserStorage.config.type }}
    datasetName: {{ .Values.filebrowserStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.filebrowserStorage.config.hostPath | default "" }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $configBasePath }}
        02-init-config:
          mountPath: {{ $configBasePath }}
        01-permissions:
          mountPath: /mnt/directories/config
  {{- range $idx, $storage := .Values.filebrowserStorage.additionalStorages }}
  {{ printf "filebrowser-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: /data{{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

{{/* Certificate */}}
{{- with .Values.filebrowserNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: filebrowser-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      filebrowser:
        filebrowser:
          mountPath: {{ $configBasePath }}/certs
          readOnly: true

scaleCertificate:
  filebrowser-cert:
    enabled: true
    id: {{ . }}
{{- end -}}
{{- end -}}
