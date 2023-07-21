{{- define "pgadmin.persistence" -}}
persistence:
  config:
    enabled: true
    type: {{ .Values.pgadminStorage.config.type }}
    datasetName: {{ .Values.pgadminStorage.config.datasetName | default "" }}
    hostPath: {{ .Values.pgadminStorage.config.hostPath | default "" }}
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /var/lib/pgadmin
        01-permissions:
          mountPath: /mnt/directories/pgadmin
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.pgadminStorage.additionalStorages }}
  {{ printf "pgadmin-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}

  {{- if .Values.pgadminNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: pgadmin-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: server.key
      - key: tls.crt
        path: server.cert
    targetSelector:
      pgadmin:
        pgadmin:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  pgadmin-cert:
    enabled: true
    id: {{ .Values.pgadminNetwork.certificateID }}
  {{- end }}
{{- end -}}
