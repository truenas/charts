{{- define "minio.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $url := urlParse .Values.minioNetwork.consoleUrl -}}
  {{- $protocol := $url.scheme -}}
  {{- $host := $url.hostname -}}
  {{- $port := $url.host | replace $host "" | replace ":" "" -}}
  {{/* If user used SCALE certificate, then force https */}}
  {{- if eq "https" (include "minio.scheme" $) -}}
    {{- $protocol = "https" -}}
  {{- end }}
  path: "/"
  port: {{ $port | default .Values.minioNetwork.webPort | quote }}
  protocol: {{ $protocol | default "http" }}
  host: {{ $host | default "$node_ip" }}
{{- end -}}
