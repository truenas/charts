{{- define "netboot.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netbootStorage.config) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: /config
  assets:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netbootStorage.assets) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: /assets
  {{- range $idx, $storage := .Values.netbootStorage.additionalStorages }}
  {{ printf "netboot-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: {{ $storage.mountPath }}
  {{- end -}}
{{- end -}}
