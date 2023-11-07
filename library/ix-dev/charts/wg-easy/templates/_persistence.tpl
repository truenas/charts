{{- define "wgeasy.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.wgStorage.config) | nindent 4 }}
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
  {{ printf "wgeasy-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      wgeasy:
        wgeasy:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
