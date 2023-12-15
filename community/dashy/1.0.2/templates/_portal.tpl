{{- define "dashy.portal" -}}
{{- $protocol := "http" -}}
{{- if .Values.dashyNetwork.certificateID -}}
  {{- $protocol = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.dashyNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: $node_ip
{{- end -}}
