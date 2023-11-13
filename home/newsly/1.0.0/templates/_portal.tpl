{{- define "newsly.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: 59687
  protocol: http
  host: $node_ip
{{- end -}}
