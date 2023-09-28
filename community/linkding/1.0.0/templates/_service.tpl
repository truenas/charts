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
