{{- define "actual.service" -}}
service:
  actual:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: actual
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.actualNetwork.webPort }}
        nodePort: {{ .Values.actualNetwork.webPort }}
        targetSelector: actual
{{- end -}}
