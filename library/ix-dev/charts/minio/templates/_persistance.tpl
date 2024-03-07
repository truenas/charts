{{- define "minio.persistence" -}}
persistence:
  export:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.minioStorage.export) | nindent 4 }}
    targetSelector:
      minio:
        minio:
          mountPath: /export
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
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.minioStorage.pgData
            "pgBackup" .Values.minioStorage.pgBackup
      ) | nindent 2 }}
{{- end -}}
