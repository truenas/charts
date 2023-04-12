{{- define "npm.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.npmNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
