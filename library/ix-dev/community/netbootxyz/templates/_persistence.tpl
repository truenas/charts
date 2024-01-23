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
        {{- if and (eq .Values.netbootStorage.assets.type "ixVolume")
                  (not (.Values.netbootStorage.assets.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/assets
        {{- end }}
  {{- range $idx, $storage := .Values.netbootStorage.additionalStorages }}
  {{ printf "netboot-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      netboot:
        netboot:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end -}}
{{- end -}}
