{{- define "jenkins.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $protocol := "http" -}}
  {{- if .Values.jenkinsNetwork.certificateID -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/login"
  host: $node_ip
  protocol: {{ $protocol }}
  port: {{ .Values.jenkinsNetwork.webPort | quote }}
{{- end -}}
