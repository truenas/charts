{{- define "nextcloud.portal" -}}
{{- $protocol := "http" -}}
{{- if .Values.ncNetwork.certificateID -}}
  {{- $protocol = "https" -}}
{{- end -}}
{{- $port := .Values.ncNetwork.webPort -}}
{{- if .Values.ncNetwork.nginx.useDifferentAccessPort -}}
  {{- $port = .Values.ncNetwork.nginx.externalAccessPort -}}
{{- end }}
{{- $host := "$node_ip" -}}
{{- if .Values.ncConfig.host -}}
  {{- $host = .Values.ncConfig.host -}}
  {{- if contains ":" .Values.ncConfig.host -}}
    {{- $host = (split ":" $host)._0 -}}
    {{- $port = (split ":" $host)._1 -}}
  {{- end -}}
{{- end -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port | quote }}
  path: "/"
  protocol: {{ $protocol }}
  host: {{ $host | quote }}
{{- end -}}
