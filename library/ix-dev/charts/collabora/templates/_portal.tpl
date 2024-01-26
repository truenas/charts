{{- define "collabora.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  {{/* TODO:
  port: {{ $port | quote }}
  protocol: {{ $protocol }}
  host: {{ $host }}
  */}}
{{- end -}}
