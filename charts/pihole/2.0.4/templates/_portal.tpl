{{- define "pihole.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.piholeNetwork.webPort | quote }}
  path: "/admin/"
  protocol: "http"
  host: $node_ip
{{- end -}}
