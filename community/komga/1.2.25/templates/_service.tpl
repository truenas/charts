{{- define "komga.service" -}}
service:
  komga:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: komga
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.komgaNetwork.webPort }}
        nodePort: {{ .Values.komgaNetwork.webPort }}
        targetSelector: komga
{{- end -}}
