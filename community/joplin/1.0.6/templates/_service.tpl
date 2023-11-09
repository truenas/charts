{{- define "joplin.service" -}}
service:
  joplin:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: joplin
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.joplinNetwork.webPort }}
        nodePort: {{ .Values.joplinNetwork.webPort }}
        targetSelector: joplin
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
