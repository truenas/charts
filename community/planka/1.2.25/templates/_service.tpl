{{- define "planka.service" -}}
service:
  planka:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: planka
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.plankaNetwork.webPort }}
        nodePort: {{ .Values.plankaNetwork.webPort }}
        targetSelector: planka
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
