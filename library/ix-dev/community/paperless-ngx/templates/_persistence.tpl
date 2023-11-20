{{- define "paperless.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.data) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.data) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/data
  media:
    enabled: true
    {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.media) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.media) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/media
  consume:
    enabled: true
    {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.consume) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.paperlessStorage.consume) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: /usr/src/paperless/consume
  trash:
    enabled: true
    {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.trash) }}
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
    {{- include "paperless.storage.ci.migration" (dict "storage" $storage) }}
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      paperless:
        paperless:
          mountPath: {{ $storage.mountPath }}
  {{- end }}

  {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.pgData) }}
  {{- include "paperless.storage.ci.migration" (dict "storage" .Values.paperlessStorage.pgBackup) }}
  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.paperlessStorage.pgData
            "pgBackup" .Values.paperlessStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}

{{/* TODO: Remove on the next version bump, eg 1.2.0+ */}}
{{- define "paperless.storage.ci.migration" -}}
  {{- $storage := .storage -}}

  {{- if $storage.hostPath -}}
    {{- $_ := set $storage "hostPathConfig" dict -}}
    {{- $_ := set $storage.hostPathConfig "hostPath" $storage.hostPath -}}
  {{- end -}}
{{- end -}}
