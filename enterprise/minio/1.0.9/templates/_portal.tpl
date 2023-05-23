{{- define "minio.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- $host := .Values.minioNetwork.consoleUrl | default "$node_ip" -}}
  {{- $host = $host | replace "https://" "" -}}
  {{- $host = $host | replace "http://" "" }}
  path: "/"
  port: {{ .Values.minioNetwork.webPort | quote }}
  protocol: {{ include "minio.scheme" $ }}
  host: {{ $host }}
{{- end -}}
