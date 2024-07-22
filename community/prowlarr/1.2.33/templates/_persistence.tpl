{{- define "prowlarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.prowlarrStorage.config) | nindent 4 }}
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /config
        {{- if and (eq .Values.prowlarrStorage.config.type "ixVolume")
                  (not (.Values.prowlarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.prowlarrStorage.additionalStorages }}
  {{ printf "prowlarr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      prowlarr:
        prowlarr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
