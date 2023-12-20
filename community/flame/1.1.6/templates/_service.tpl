{{- define "flame.service" -}}
service:
  flame:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: flame
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.flameNetwork.webPort }}
        nodePort: {{ .Values.flameNetwork.webPort }}
        targetSelector: flame
{{- end -}}
