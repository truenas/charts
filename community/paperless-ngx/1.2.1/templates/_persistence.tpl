{{- define "paperless.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.data) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/data
  media:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.media) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/media
  consume:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.consume) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/consume
  trash:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.trash) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/trash
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
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.paperlessStorage.pgData
            "pgBackup" .Values.paperlessStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
