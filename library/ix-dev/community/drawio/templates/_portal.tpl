{{- define "drawio.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/?offline=1&https=0"
  port: {{ .Values.drawioNetwork.httpPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
