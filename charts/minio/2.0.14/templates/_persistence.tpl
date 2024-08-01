{{- define "minio.persistence" -}}
persistence:
  {{- if not .Values.minioStorage.distributedMode }}
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

  {{- if .Values.minioNetwork.certificateID }}
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
    targetSelector:
      minio:
        minio:
          mountPath: /etc/minio/certs
          readOnly: true
  certca:
    enabled: true
    type: secret
    objectName: minio-cert
    defaultMode: "0600"
    items:
      - key: tls.crt
        path: public.crt
    targetSelector:
      minio:
        minio:
          mountPath: /etc/minio/certs/CAs
          readOnly: true

scaleCertificate:
  minio-cert:
    enabled: true
    id: {{ .Values.minioNetwork.certificateID }}
  {{- end }}

{{- end -}}
