{{- define "emby.portal" -}}
{{- $port := .Values.embyNetwork.webPort -}}
{{- if .Values.embyNetwork.hostNetwork -}}
  {{- $port = 8096 -}}
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
