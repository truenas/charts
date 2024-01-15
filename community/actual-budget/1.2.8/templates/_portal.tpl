{{- define "actual.portal" -}}
{{- $proto := "http" -}}
{{- if .Values.actualNetwork.certificateID -}}
  {{- $proto = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.actualNetwork.webPort | quote }}
  protocol: {{ $proto }}
  host: $node_ip
{{- end -}}
