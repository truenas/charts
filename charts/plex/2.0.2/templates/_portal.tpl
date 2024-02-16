{{- define "plex.portal" -}}
{{- $port := .Values.plexNetwork.webPort -}}
{{- if .Values.plexNetwork.hostNetwork -}}
  {{- $port = 32400 -}}
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
