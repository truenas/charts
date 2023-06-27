{{- define "jellyfin.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{- $port := .Values.jellyfinNetwork.webPort -}}
  {{- if .Values.jellyfinNetwork.hostNetwork -}}
    {{- $port = 8096 -}}
  {{- end }}
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
