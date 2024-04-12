{{- define "nextcloud.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.ncNetwork.webPort | quote }}
  path: "/"
  protocol: "http"
  host: $node_ip
{{- end -}}
