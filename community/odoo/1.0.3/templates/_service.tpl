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
  {{- include "ix.v1.common.app.postgresService" $ | nindent 2 }}

{{- end -}}
