{{- define "pgadmin.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $protocol := "http" -}}
  {{- if .Values.pgadminNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/"
  port: {{ .Values.pgadminNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: $node_ip
{{- end -}}
