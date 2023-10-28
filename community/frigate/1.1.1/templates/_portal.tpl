{{- define "frigate.portal" -}}
  {{- $port := .Values.frigateNetwork.webPort -}}
  {{- if .Values.frigateNetwork.hostNetwork -}}
    {{- $port = 5000 -}}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ $port | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
