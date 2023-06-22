{{- define "minio.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $host := .Values.minioNetwork.consoleUrl | default "$node_ip" -}}
  {{- $protocol := "http" -}}

  {{/* Extract protocol from user defined URL */}}
  {{- $protocol := regexReplaceAll "(.*)://.*" $host "${1}" -}}
  {{- if not $protocol -}}
    {{/* If no protocol found, default to http */}}
    {{- $protocol = "http" -}}
  {{- end -}}

  {{/* If we user used SCALE certificate, then force https */}}
  {{- if eq "https" (include "minio.scheme" $) -}}
    {{- $protocol = "https" -}}
  {{- end -}}

  {{/* Extract host with port from user defined URL */}}
  {{- $host := regexReplaceAll ".*://(.*)" $host "${1}" -}}

  {{/* Extract port from user defined URL */}}
  {{- $port := regexReplaceAll ".*:(.*)" $host "${1}" -}}
  {{- if not $port -}}
    {{/* If no port is defined, use the minio port */}}
    {{- $port = .Values.minioNetwork.webPort -}}
  {{- end -}}

  {{/* Extract host without port from user defined URL */}}
  {{- $host = regexReplaceAll "(.*):.*" $host "${1}" }}
  path: "/"
  port: {{ $port | quote }}
  protocol: {{ $protocol }}
  host: {{ $host }}
{{- end -}}
