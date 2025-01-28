{{- define "drawio.service" -}}
service:
  drawio:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: drawio
    ports:
      http:
        enabled: true
        primary: true
        port: {{ .Values.drawioNetwork.httpPort }}
        nodePort: {{ .Values.drawioNetwork.httpPort }}
        targetPort: 8080
        targetSelector: drawio
      https:
        enabled: true
        port: {{ .Values.drawioNetwork.httpsPort }}
        nodePort: {{ .Values.drawioNetwork.httpsPort }}
        targetPort: 8443
        targetSelector: drawio
{{- end -}}
