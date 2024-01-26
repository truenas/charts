{{- define "briefkasten.portal" -}}
  {{- $host := "$node_ip" -}}
  {{- $port := "" -}}
  {{- $protocol := "http" -}}
  {{- if hasPrefix "https://" .Values.briefkastenConfig.url -}}
    {{- $protocol = "https" -}}
  {{- end -}}

  {{- with .Values.briefkastenConfig.url -}} {{/* Trim protocol and trailing slash */}}
    {{- $host = . | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/" -}}

    {{- if contains ":" $host -}}
      {{- $port = (split ":" $host)._1 -}}
      {{- $host = (split ":" $host)._0 -}}
    {{- end -}}

    {{- if not $port -}}
      {{- if eq $protocol "https" -}}
        {{- $port = "443" -}}
      {{- else -}}
        {{- $port = "80" -}}
      {{- end -}}
    {{- end -}}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ $port | quote }}
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
