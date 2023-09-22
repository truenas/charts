{{- define "omada.persistence" -}}
persistence:
  data:
    enabled: true
    type: {{ .Values.omadaStorage.data.type }}
    datasetName: {{ .Values.omadaStorage.data.datasetName | default "" }}
    hostPath: {{ .Values.omadaStorage.data.hostPath | default "" }}
    targetSelector:
      omada:
        omada:
          mountPath: /opt/tplink/EAPController/data
        01-permissions:
          mountPath: /mnt/directories/data
  logs:
    enabled: true
    type: {{ .Values.omadaStorage.logs.type }}
    datasetName: {{ .Values.omadaStorage.logs.datasetName | default "" }}
    hostPath: {{ .Values.omadaStorage.logs.hostPath | default "" }}
    targetSelector:
      omada:
        omada:
          mountPath: /opt/tplink/EAPController/logs
        01-permissions:
          mountPath: /mnt/directories/logs
  tmp:
    enabled: true
    type: emptyDir
    targetSelector:
      omada:
        omada:
          mountPath: /tmp
  {{- range $idx, $storage := .Values.omadaStorage.additionalStorages }}
  {{ printf "omada-%v" (int $idx) }}:
    enabled: true
    type: {{ $storage.type }}
    datasetName: {{ $storage.datasetName | default "" }}
    hostPath: {{ $storage.hostPath | default "" }}
    targetSelector:
      omada:
        omada:
          mountPath: {{ $storage.mountPath }}
        01-permissions:
          mountPath: /mnt/directories{{ $storage.mountPath }}
  {{- end -}}

  {{- if .Values.omadaNetwork.certificateID }}
  cert:
    enabled: true
    type: secret
    objectName: omada-cert
    defaultMode: "0600"
    items:
      - key: tls.key
        path: tls.key
      - key: tls.crt
        path: tls.crt
    targetSelector:
      omada:
        omada:
          mountPath: /cert
          readOnly: true

scaleCertificate:
  omada-cert:
    enabled: true
    id: {{ .Values.omadaNetwork.certificateID }}
    {{- end -}}
{{- end -}}
