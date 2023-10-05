{{- define "sftpgo.portal" -}}
{{- $protocol := "http" -}}
{{- if .Values.sftpgoNetwork.certificateID -}}
  {{- $protocol = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/web/admin"
  port: {{ .Values.sftpgoNetwork.webPort | quote }}
  protocol: {{ $protocol | quote }}
  host: $node_ip
{{- end -}}
