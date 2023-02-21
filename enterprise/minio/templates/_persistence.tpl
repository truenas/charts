{{- define "minio.persistence" -}}
data:
  enabled: true
  type: {{ .Values.minio.storage.data.type }}
  datasetName: {{ .Values.minio.storage.data.datasetName | default "" }}
  hostPath: {{ .Values.minio.storage.data.hostPath | default "" }}
  targetSelector:
    main:
      main:
        mountPath: /data
# Minio writes temporary files to this directory.
# Adding this as an emptyDir, so we don't have to set readOnlyRootFilesystem to false
tempdir:
  enabled: true
  type: emptyDir
  targetSelector:
    main:
      main:
        mountPath: /.minio
  {{- if .Values.minio.certificate_id }}
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
    main:
      main:
        mountPath: /etc/minio/certs
        readOnly: true
  {{- end -}}
{{- end -}}
