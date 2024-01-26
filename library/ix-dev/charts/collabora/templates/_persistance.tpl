{{- define "collabora.persistence" -}}
persistence:
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      collabora:
        collabora:
          mountPath: /tmp
      nginx:
        nginx:
          mountPath: /tmp
  {{- if .Values.collaboraNetwork.certificateID }}
  nginx-conf:
    enabled: true
    type: configmap
    objectName: nginx-conf
    defaultMode: "0600"
    items:
      - key: nginx.conf
        path: nginx.conf
    targetSelector:
      nginx:
        nginx:
          mountPath: /etc/nginx
          readOnly: true
  cert:
    enabled: true
    type: secret
    objectName: collabora-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: server.key
      - key: tls.crt
        path: server.crt
    targetSelector:
      nginx:
        nginx:
          mountPath: /etc/nginx
          readOnly: true
  {{- end }}
  {{- range $idx, $storage := .Values.collaboraStorage.additionalStorages }}
  {{ printf "collabora-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      collabora:
        collabora:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
