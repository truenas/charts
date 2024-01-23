{{- define "home-assistant.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.haNetwork.webPort | quote }}
  path: "/"
  protocol: "http"
  host: $node_ip
{{- end -}}
