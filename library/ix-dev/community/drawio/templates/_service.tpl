{{- define "drawio.service" -}}
service:
  drawio:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: drawio
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.drawioNetwork.webPort }}
        nodePort: {{ .Values.drawioNetwork.webPort }}
        targetPort: {{ ternary 8080 8443 .Values.drawioNetwork.useHttp }}
        targetSelector: drawio
{{- end -}}
