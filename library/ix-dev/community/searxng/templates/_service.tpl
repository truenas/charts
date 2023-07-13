{{- define "searxng.service" -}}
service:
  searxng:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: searxng
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.searxngNetwork.webPort }}
        nodePort: {{ .Values.searxngNetwork.webPort }}
        targetSelector: searxng
{{- end -}}
