{{- define "sftpgo.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/web/admin"
  port: {{ .Values.sftpgoNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
