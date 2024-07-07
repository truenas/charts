{{- define "paperless.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.paperlessNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
