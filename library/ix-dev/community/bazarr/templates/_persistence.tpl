{{- define "bazarr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.bazarrStorage.config) | nindent 4 }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /config
        {{- if and (eq .Values.bazarrStorage.config.type "ixVolume")
                  (not (.Values.bazarrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      bazarr:
        bazarr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.bazarrStorage.additionalStorages }}
  {{ printf "bazarr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      bazarr:
        bazarr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
