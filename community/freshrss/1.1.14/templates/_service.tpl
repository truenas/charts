{{- define "freshrss.service" -}}
service:
  freshrss:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: freshrss
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.freshrssNetwork.webPort }}
        nodePort: {{ .Values.freshrssNetwork.webPort }}
        targetSelector: freshrss
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
