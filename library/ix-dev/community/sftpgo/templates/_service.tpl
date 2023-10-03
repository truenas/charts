{{- define "sftpgo.service" -}}
service:
  sftpgo:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: sftpgo
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.sftpgoNetwork.webPort }}
        nodePort: {{ .Values.sftpgoNetwork.webPort }}
        targetSelector: sftpgo
{{- end -}}
