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
  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetPort: 5432
        targetSelector: postgres
{{- end -}}
