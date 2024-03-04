{{- define "storj.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.storjNetwork.webPort | quote }}
  path: "/"
  protocol: "http"
  host: $node_ip
{{- end -}}
