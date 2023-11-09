{{- define "vikunja.service" -}}
service:
  vikunja:
    enabled: true
    primary: true
    type: ClusterIP
    targetSelector: vikunja-api
    ports:
      api:
        enabled: true
        primary: true
        port: {{ .Values.vikunjaPorts.api }}
        targetSelector: vikunja-api
  proxy:
    enabled: true
    type: NodePort
    targetSelector: vikunja-proxy
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.vikunjaNetwork.webPort }}
        nodePort: {{ .Values.vikunjaNetwork.webPort }}
        targetSelector: vikunja-proxy
  frontend:
    enabled: true
    type: ClusterIP
    targetSelector: vikunja-frontend
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.vikunjaPorts.frontHttp }}
        targetSelector: vikunja-frontend
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
