{{- define "netboot.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netbootStorage.config) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: /config
        {{- if and (eq .Values.netbootStorage.config.type "ixVolume")
                  (not (.Values.netbootStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/netbootxyz/config
        {{- end }}
  assets:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.netbootStorage.assets) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: /assets
        {{- if and (eq .Values.netbootStorage.assets.type "ixVolume")
                  (not (.Values.netbootStorage.assets.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/netbootxyz/assets
        {{- end }}
{{- end -}}
