{{- define "n8n.persistence" -}}
persistence:
  data:
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" .Values.n8nStorage.data) | nindent 4 }}
    targetSelector:
      n8n:
        n8n:
          mountPath: /data
        {{- if and (eq .Values.n8nStorage.data.type "ixVolume")
                  (not (.Values.n8nStorage.data.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories/data
        {{- end }}
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      n8n:
        n8n:
          mountPath: /tmp
  cache:
    enabled: true
    type: emptyDir
    targetSelector:
      n8n:
        n8n:
          mountPath: /.cache
  {{- range $idx, $storage := .Values.n8nStorage.additionalStorages }}
  {{ printf "n8n-%v:" (int $idx) }}
    enabled: true
    {{- include "ix.v1.common.app.storageOptions" (dict "storage" $storage) | nindent 4 }}
    targetSelector:
      n8n:
        n8n:
          mountPath: {{ $storage.mountPath }}
        {{- if and (eq $storage.type "ixVolume") (not ($storage.ixVolumeConfig | default dict).aclEnable) }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
        {{- end }}
  {{- end }}

  {{- include "ix.v1.common.app.postgresPersistence"
      (dict "pgData" .Values.n8nStorage.pgData
            "pgBackup" .Values.n8nStorage.pgBackup
      ) | nindent 2 }}

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
