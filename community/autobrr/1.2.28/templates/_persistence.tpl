{{- define "autobrr.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.autobrrStorage.config) | nindent 4 }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /config
        {{- if and (eq .Values.autobrrStorage.config.type "ixVolume")
                  (not (.Values.autobrrStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      autobrr:
        autobrr:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.autobrrStorage.additionalStorages }}
  {{ printf "autobrr-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      autobrr:
        autobrr:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
