{{- define "homarr.persistence" -}}
persistence:
  configs:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.configs) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/data/configs
        {{- if and (eq .Values.homarrStorage.configs.type "ixVolume")
                  (not (.Values.homarrStorage.configs.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/configs
        {{- end }}
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.data) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /data
        {{- if and (eq .Values.homarrStorage.data.type "ixVolume")
                  (not (.Values.homarrStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  icons:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.homarrStorage.icons) | nindent 4 }}
    targetSelector:
      homarr:
        homarr:
          mountPath: /app/public/icons
        {{- if and (eq .Values.homarrStorage.icons.type "ixVolume")
                  (not (.Values.homarrStorage.icons.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/icons
        {{- end }}
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
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
