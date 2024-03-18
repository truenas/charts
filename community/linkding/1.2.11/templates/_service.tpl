{{- define "linkding.service" -}}
service:
  linkding:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: linkding
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.linkdingNetwork.webPort }}
        nodePort: {{ .Values.linkdingNetwork.webPort }}
        targetSelector: linkding
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
