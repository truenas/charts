{{- define "pigallery.persistence" -}}
persistence:
  config:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pigalleryStorage.config) | nindent 4 }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/config
        {{- if and (eq .Values.pigalleryStorage.config.type "ixVolume")
                  (not (.Values.pigalleryStorage.config.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/config
        {{- end }}
  db:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pigalleryStorage.db) | nindent 4 }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/db
        {{- if and (eq .Values.pigalleryStorage.db.type "ixVolume")
                  (not (.Values.pigalleryStorage.db.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/db
        {{- end }}
  media:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pigalleryStorage.media) | nindent 4 }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/media
        {{- if and (eq .Values.pigalleryStorage.media.type "ixVolume")
                  (not (.Values.pigalleryStorage.media.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/media
        {{- end }}
  thumbnails:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.pigalleryStorage.thumbnails) | nindent 4 }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: /app/data/thumbnails
        {{- if and (eq .Values.pigalleryStorage.thumbnails.type "ixVolume")
                  (not (.Values.pigalleryStorage.thumbnails.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/thumbnails
         {{- end }}
  {{- range $idx, $storage := .Values.pigalleryStorage.additionalStorages }}
  {{ printf "pigallery-%v" (int $idx) }}:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      pigallery:
        pigallery:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}
{{- end -}}
