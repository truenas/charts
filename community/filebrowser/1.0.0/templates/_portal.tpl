{{- define "filebrowser.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $scheme := "http" -}}
  {{- if .Values.filebrowserNetwork.certificateID -}}
    {{- $scheme = "https" -}}
  {{- end }}
  path: "/"
  port: {{ .Values.filebrowserNetwork.webPort | quote }}
  protocol: {{ $scheme }}
  host: $node_ip
{{- end -}}
