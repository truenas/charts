{{- define "planka.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $protocol := "http" -}}
  {{- if hasPrefix "https://" .Values.plankaConfig.baseURL -}}
    {{- $protocol = "https" -}}
  {{- end -}}
  {{- $host := "$node_ip" -}}
  {{- $port := .Values.plankaNetwork.webPort -}}
  {{- with .Values.plankaConfig.baseURL -}} {{/* Trim protocol and trailing slash */}}
    {{- $host = (. | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") -}}
    {{- $host = mustRegexReplaceAll "(.*):[0-9]+" $host "${1}" -}}
    {{- $tempPort := . | trimPrefix $protocol | trimPrefix "://" | trimPrefix $host | trimPrefix ":" -}}
    {{- if $tempPort -}}
      {{- $port = $tempPort -}}
    {{- end -}}
    {{- if not $tempPort -}}
      {{- if eq $protocol "https" -}}
        {{- $port = "443" -}}
      {{- else -}}
        {{- $port = "80" -}}
      {{- end -}}
    {{- end -}}
  {{- end }}
  path: "/"
  port: {{ $port | quote }}
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
