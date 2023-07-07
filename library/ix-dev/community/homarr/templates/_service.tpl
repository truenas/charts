{{- define "homarr.service" -}}
service:
  homarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: homarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.homarrNetwork.webPort }}
        nodePort: {{ .Values.homarrNetwork.webPort }}
        targetSelector: homarr
{{- end -}}
