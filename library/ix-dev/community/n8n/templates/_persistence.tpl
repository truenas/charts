{{- define "n8n.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.n8nStorage.data.type }}
    datasetName: {{ .Values.n8nStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.n8nStorage.data.hostPath | default "" }}
    targetSelector:
      n8n:
        n8n:
          mountPath: /data
        01-permissions:
          mountPath: /mnt/directories/data
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      n8n:
        n8n:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.n8nStorage.additionalStorages }}
  {{ printf "n8n-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      n8n:
        n8n:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end }}
  # Postgres
  postgresdata:
    enabled: true
    type: {{ .Values.n8nStorage.pgData.type }}
    datasetName: {{ .Values.n8nStorage.pgData.datasetName | default "" }}
    hostPath: {{ .Values.n8nStorage.pgData.hostPath | default "" }}
    targetSelector:
      # Postgres pod
      postgres:
        # Postgres container
        postgres:
          mountPath: /var/lib/postgresql/data
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_data
  # Postgres backup
  postgresbackup:
    enabled: true
    type: {{ .Values.n8nStorage.pgBackup.type }}
    datasetName: {{ .Values.n8nStorage.pgBackup.datasetName | default "" }}
    hostPath: {{ .Values.n8nStorage.pgBackup.hostPath | default "" }}
    targetSelector:
      # Postgres backup pod
      postgresbackup:
        # Postgres backup container
        postgresbackup:
          mountPath: /postgres_backup
        # Permissions container
        permissions:
          mountPath: /mnt/directories/postgres_backup
  {{- if .Values.n8nNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: n8n-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      n8n:
        n8n:
          mountPath: /certs
          readOnly: true

scaleCertificate:
  n8n-cert:
    enabled: true
    id: {{ .Values.n8nNetwork.certificateID }}
    {{- end }}
{{- end -}}
