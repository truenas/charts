{{- define "minio.portal" -}}
  {{- $proto := "http" -}}
  {{- if .Values.minioNetwork.certificateID -}}
    {{- $proto = "https" -}}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.minioNetwork.consolePort | quote }}
  protocol: {{ $proto }}
  host: "$node_ip"
{{- end -}}
