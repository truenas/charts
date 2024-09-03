{{- define "unifi.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.unifiNetwork.webHttpsPort | quote }}
  protocol: https
  host: $node_ip
{{- end -}}
