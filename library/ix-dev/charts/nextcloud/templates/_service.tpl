{{- define "nextcloud.service" -}}
service:
  nextcloud:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: nextcloud
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.ncNetwork.webPort }}
        nodePort: {{ .Values.ncNetwork.webPort }}
        {{- if not .Values.ncNetwork.certificateID }}
        targetPort: 80
        {{- end }}
        targetSelector: nextcloud
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}
{{- end -}}
