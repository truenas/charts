{{- define "invidious.service" -}}
service:
  invidious:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: invidious
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.invidiousNetwork.webPort }}
        nodePort: {{ .Values.invidiousNetwork.webPort }}
        targetSelector: invidious
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
