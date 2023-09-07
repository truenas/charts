{{- define "n8n.portal" -}}
  {{- $protocol := "http" -}}
  {{- if .Values.n8nNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end -}}
  {{- $host := .Values.n8nConfig.webHost -}}
  {{- $port := .Values.n8nNetwork.webPort -}}
  {{- if contains ":" $host -}}
      {{ $port = (split ":" $host)._1 }}
      {{ $host = (split ":" $host)._0 }}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port }}
  path: "/"
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
