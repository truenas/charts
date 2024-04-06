{{- define "home-assistant.service" -}}
service:
  home-assistant:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: home-assistant
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.haNetwork.webPort }}
        nodePort: {{ .Values.haNetwork.webPort }}
        targetPort: 8123
        targetSelector: home-assistant
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
