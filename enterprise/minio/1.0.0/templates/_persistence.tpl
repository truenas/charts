{{- define "minio.persistence" -}}
persistence:
  {{- range $idx, $storage := .Values.minio.storage }}
  {{ printf "data%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      minio:
        minio:
          mountPath: {{ $storage.mountPath }}
        permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
  # Minio writes temporary files to this directory. Adding this as an emptyDir,
  # So we don't have to set readOnlyRootFilesystem to false
  tempdir:
    enabled: true
    type: emptyDir
    targetSelector:
      minio:
        minio:
          mountPath: /.minio

  {{- if .Values.minio.network.certificate_id }}
  cert:
    enabled: true
    type: secret
    objectName: minio-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: private.key
      - key: tls.crt
        path: public.crt
      - key: tls.crt
        path: CAs/public.crt
    targetSelector:
      minio:
        minio:
          mountPath: /.minio/certs
          readOnly: true
    {{- end -}}

{{- if .Values.logsearch.enabled }}
  postgresdata:
    enabled: true
    type: {{ .Values.logsearch.postgres_data.type }}
    datasetName: {{ .Values.logsearch.postgres_data.datasetName | default "" }}
    hostPath: {{ .Values.logsearch.postgres_data.hostPath | default "" }}
    targetSelector:
      postgres:
        postgres:
          mountPath: /var/lib/postgresql/data
        permissions:
          mountPath: /mnt/directories/posgres_data
  postgresbackup:
    enabled: true
    type: {{ .Values.logsearch.postgres_backup.type }}
    datasetName: {{ .Values.logsearch.postgres_backup.datasetName | default "" }}
    hostPath: {{ .Values.logsearch.postgres_backup.hostPath | default "" }}
    targetSelector:
      postgresbackup:
        postgresbackup:
          mountPath: /postgres_backup
        permissions:
          mountPath: /mnt/directories/posgres_backup
  {{- end -}}
{{- end -}}
