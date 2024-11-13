{{- define "homer.service" -}}
service:
  homer:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: homer
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.homerNetwork.webPort }}
        nodePort: {{ .Values.homerNetwork.webPort }}
        targetSelector: homer
{{- end -}}
