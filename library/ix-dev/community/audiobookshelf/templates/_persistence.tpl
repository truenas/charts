{{- define "audiobookshelf.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.audiobookshelfStorage.config) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: /config
        {{- if and (eq .Values.audiobookshelfStorage.config.type "ixVolume")
                  (not (.Values.audiobookshelfStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  metadata:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.audiobookshelfStorage.metadata) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: /metadata
        {{- if and (eq .Values.audiobookshelfStorage.metadata.type "ixVolume")
                  (not (.Values.audiobookshelfStorage.metadata.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/metadata
        {{- end }}
  {{- range $idx, $storage := .Values.audiobookshelfStorage.additionalStorages }}
  {{ printf "audiobookshelf-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      audiobookshelf:
        audiobookshelf:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
