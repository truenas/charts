{{- define "roundcube.service" -}}
service:
  roundcube:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: roundcube
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.roundcubeNetwork.webPort }}
        nodePort: {{ .Values.roundcubeNetwork.webPort }}
        targetPort: 80
        targetSelector: roundcube
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
