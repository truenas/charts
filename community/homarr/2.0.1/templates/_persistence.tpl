{{- define "homarr.persistence" -}}
persistence:
  configs:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.configs) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/data/configs
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.data) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /data
  icons:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.icons) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/public/icons
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
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
