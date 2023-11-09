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
    {{- $size := "" -}}
    {{- if $storage.size -}}
      {{- $size = (printf "%vGi" $storage.size) -}}
    {{- end }}
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    server: {{ $storage.server | default "" }}
    share: {{ $storage.share | default "" }}
    domain: {{ $storage.domain | default "" }}
    username: {{ $storage.username | default "" }}
    password: {{ $storage.password | default "" }}
    size: {{ $size }}
    {{- if eq $storage.type "smb-pv-pvc" }}
    mountOptions:
      - key: noperm
    {{- end }}
    targetSelector:
      n8n:
        n8n:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
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
