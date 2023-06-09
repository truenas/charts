{{- define "grafana.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $host := "$node_ip" -}}
  {{- $protocol := "http" -}}
  {{- if .Values.grafanaNetwork.certificateID -}}
    {{- $protocol = "https" -}}
    {{- if .Values.grafanaNetwork.rootURL -}}
      {{- $host = .Values.grafanaNetwork.rootURL -}}
      {{- $host = ($host | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") -}}
      {{- $host = (mustRegexReplaceAll "(.*):[0-9]+" $host "${1}") -}}
    {{- end -}}
  {{- end }}
  path: "/"
  port: {{ .Values.grafanaNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
