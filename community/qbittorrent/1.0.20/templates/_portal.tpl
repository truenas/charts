{{- define "qbittorrent.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.qbitNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
