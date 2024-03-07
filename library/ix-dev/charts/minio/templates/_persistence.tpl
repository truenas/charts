{{- define "minio.persistence" -}}
persistence:
  export:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.minioStorage.export) | nindent 4 }}
    targetSelector:
      minio:
        minio:
          mountPath: {{ .Values.minioStorage.export.mountPath }}
        {{- if and (eq .Values.minioStorage.export.type "ixVolume")
                  (not (.Values.minioStorage.export.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/export
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      minio:
        minio:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.minioStorage.additionalStorages }}
  {{ printf "minio-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      minio:
        minio:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.minioStorage.pgData
            "pgBackup" .Values.minioStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
