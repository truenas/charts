{{- define "mealie.service" -}}
service:
  mealie:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: mealie
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.mealieNetwork.webPort }}
        nodePort: {{ .Values.mealieNetwork.webPort }}
        targetSelector: mealie
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
