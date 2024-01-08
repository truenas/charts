{{- define "roundcube.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.roundcubeNetwork.webPort | quote }}
  path: "/"
  protocol: http
  host: $node_ip
{{- end -}}
