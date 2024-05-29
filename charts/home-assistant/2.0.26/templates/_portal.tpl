{{- define "home-assistant.portal" -}}
{{- $port := .Values.haNetwork.webPort -}}
{{- if .Values.haNetwork.hostNetwork -}}
  {{- $port = 8123 -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port | quote }}
  path: "/"
  protocol: "http"
  host: $node_ip
{{- end -}}
