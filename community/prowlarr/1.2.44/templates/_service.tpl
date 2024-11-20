{{- define "prowlarr.service" -}}
service:
  prowlarr:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: prowlarr
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.prowlarrNetwork.webPort }}
        nodePort: {{ .Values.prowlarrNetwork.webPort }}
        targetSelector: prowlarr
{{- end -}}
