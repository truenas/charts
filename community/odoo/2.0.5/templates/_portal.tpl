{{- define "odoo.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  host: $node_ip
  path: /
  protocol: http
  port: {{ .Values.odooNetwork.webPort | quote }}
{{- end -}}
