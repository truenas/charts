{{- define "es.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.esNetwork.httpPort | quote }}
  protocol: {{ include "es.schema" . }}
  host: $node_ip
{{- end -}}
