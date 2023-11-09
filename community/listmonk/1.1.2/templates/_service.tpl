{{- define "listmonk.service" -}}
service:
  listmonk:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: listmonk
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.listmonkNetwork.webPort }}
        nodePort: {{ .Values.listmonkNetwork.webPort }}
        targetSelector: listmonk
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
