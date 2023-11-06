{{- define "paperless.service" -}}
service:
  paperless:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: paperless
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.paperlessNetwork.webPort }}
        nodePort: {{ .Values.paperlessNetwork.webPort }}
        targetSelector: paperless

  redis:
    enabled: true
    type: ClusterIP
    targetSelector: redis
    ports:
      redis:
        enabled: true
        primary: true
        port: 6379
        targetPort: 6379
        targetSelector: redis

  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
