{{- define "minio.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: "TODO:"
  protocol: "TODO:"
  host: "TODO: $node_ip"
{{- end -}}
