{{- define "paperless.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.data) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/data
        {{- if and (eq .Values.paperlessStorage.data.type "ixVolume")
                  (not (.Values.paperlessStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  media:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.media) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/media
        {{- if and (eq .Values.paperlessStorage.media.type "ixVolume")
                  (not (.Values.paperlessStorage.media.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/media
        {{- end }}
  consume:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.consume) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/consume
        {{- if and (eq .Values.paperlessStorage.consume.type "ixVolume")
                  (not (.Values.paperlessStorage.consume.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/consume
        {{- end }}
  trash:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.trash) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/trash
        {{- if and (eq .Values.paperlessStorage.trash.type "ixVolume")
                  (not (.Values.paperlessStorage.trash.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/trash
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      paperless:
        paperless:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.paperlessStorage.additionalStorages }}
  {{ printf "paperless-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.paperlessStorage.pgData
            "pgBackup" .Values.paperlessStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
