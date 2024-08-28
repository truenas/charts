{{- define "n8n.portal" -}}
  {{- $protocol := "http" -}}
  {{- if .Values.n8nNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end -}}
  {{- $host := .Values.n8nConfig.webHost -}}
  {{- $port := .Values.n8nNetwork.webPort -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port | quote }}
  path: "/"
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
