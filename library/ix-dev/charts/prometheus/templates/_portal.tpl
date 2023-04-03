{{- define "prometheus.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.prometheusNetwork.apiPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
