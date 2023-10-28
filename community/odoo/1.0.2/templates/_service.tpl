{{- define "odoo.service" -}}
service:
  odoo:
    enabled: true
    primary: true
    type: NodePort
    targetSelector: odoo
    ports:
      webui:
        enabled: true
        primary: true
        port: {{ .Values.odooNetwork.webPort }}
        nodePort: {{ .Values.odooNetwork.webPort }}
        targetSelector: odoo
  # Postgres
  postgres:
    enabled: true
    type: ClusterIP
    targetSelector: postgres
    ports:
      postgres:
        enabled: true
        primary: true
        port: 5432
        targetSelector: postgres
{{- end -}}
