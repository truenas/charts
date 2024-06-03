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
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      netboot:
        netboot:
          mountPath: /tmp
  varlognginx:
    enabled: true
    type: emptyDir
    targetSelector:
      netboot:
        netboot:
          mountPath: /var/log/nginx
  vartmpnginx:
    enabled: true
    type: emptyDir
    targetSelector:
      netboot:
        netboot:
          mountPath: /var/tmp/nginx
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
