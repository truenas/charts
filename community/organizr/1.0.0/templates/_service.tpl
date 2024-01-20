{{- define "organizr.service" -}}
service:
  organizr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: organizr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.organizrNetwork.webPort }}
        nodePort: {{ .Values.organizrNetwork.webPort }}
        targetPort: 80
        targetSelector: organizr
{{- end -}}
