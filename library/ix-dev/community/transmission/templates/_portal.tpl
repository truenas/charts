{{- define "transmission.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/transmission/web"
  port: {{ .Values.transmissionNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
