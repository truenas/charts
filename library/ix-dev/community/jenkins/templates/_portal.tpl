{{- define "jenkins.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $port := .Values.jenkinsNetwork.httpPort -}}
  {{- $protocol := "http" -}}
  {{- if .Values.jenkinsNetwork.certificateID -}}
    {{- $port = .Values.jenkinsNetwork.httpsPort -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/login"
  host: $node_ip
  protocol: {{ $protocol }}
  port: {{ $port | quote }}
{{- end -}}
