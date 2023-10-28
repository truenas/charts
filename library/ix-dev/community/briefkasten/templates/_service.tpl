{{- define "briefkasten.service" -}}
service:
  briefkasten:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: briefkasten
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.briefkastenNetwork.webPort }}
        nodePort: {{ .Values.briefkastenNetwork.webPort }}
        targetSelector: briefkasten
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
