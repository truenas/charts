{{- define "dashy.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.dashyStorage.data) | nindent 4 }}
    targetSelector:
      dashy:
        dashy:
          mountPath: /app/user-data
        # Mount the same dir to different path on init container
        # So we can check if `/data` is empty and copy the default
        # from /app/user-data
        init-config:
          mountPath: /data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      dashy:
        dashy:
          mountPath: /tmp

  {{- range $idx, $storage := .Values.dashyStorage.additionalStorages }}
  {{ printf "dashy-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      dashy:
        dashy:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}

  {{- if .Values.dashyNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: dashy-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      dashy:
        dashy:
          mountPath: /cert
          readOnly: true

scaleCertificate:
  dashy-cert:
    enabled: true
    id: {{ .Values.dashyNetwork.certificateID }}
    {{- end -}}
{{- end -}}
