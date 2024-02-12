{{- define "photoprism.persistence" -}}
persistence:
  import:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.import) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/import
  storage:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.storage) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/storage
  originals:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.originals) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/originals

  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.photoprismStorage.additionalStorages }}
  {{ printf "ha-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: {{ $storage.mountPath }}
  {{- end }}
{{- end -}}
