{{- define "photoprism.portal" -}}
  {{- $proto := "http" -}}
  {{- if .Values.photoprismNetwork.certificateID -}}
    {{- $proto = "https" -}}
  {{- end -}}

  {{- $host := "$node_ip" -}}
  {{- with .Values.photoprismConfig.siteURL -}} {{/* Trim protocol and trailing slash */}}
    {{- $host = (. | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") -}}
    {{- $host = mustRegexReplaceAll "(.*):[0-9]+" $host "${1}" -}}
  {{- end -}}

  {{- $port := .Values.photoprismNetwork.webPort }}

  {{- with .Values.photoprismConfig.siteURL -}} {{/* If URL is defined */}}
    {{- $p := (. | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") -}}
    {{- $p = split ":" $p -}}
    {{- if $p._1 -}} {{/* If port is defined */}}
      {{- $port = $p._1 -}}
    {{- else -}}
      {{- $port = "80" -}}
      {{- if eq $proto "https" -}}
        {{- $port = "443" -}}
      {{- end -}}
    {{- end -}}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  protocol: {{ $proto }}
  path: "/"
  host: {{ $host }}
  port: {{ $port | quote }}
{{- end -}}
