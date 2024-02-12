{{- define "photoprism.persistence" -}}
persistence:
  import:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.import) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/import
        {{- if and (eq .Values.photoprismStorage.import.type "ixVolume")
                  (not (.Values.photoprismStorage.import.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/import
        {{- end }}
  storage:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.storage) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/storage
        {{- if and (eq .Values.photoprismStorage.storage.type "ixVolume")
                  (not (.Values.photoprismStorage.storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/storage
        {{- end }}
  originals:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.photoprismStorage.originals) | nindent 4 }}
    targetSelector:
      photoprism:
        photoprism:
          mountPath: /photoprism/originals
        {{- if and (eq .Values.photoprismStorage.originals.type "ixVolume")
                  (not (.Values.photoprismStorage.originals.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/originals
        {{- end }}
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
