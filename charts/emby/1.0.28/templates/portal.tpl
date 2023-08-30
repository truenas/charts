apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- if .Values.hostNetwork }}
  port: "8096"
  {{- else }}
  port: {{ .Values.embyServerHttp.port | quote }}
  {{- end }}
