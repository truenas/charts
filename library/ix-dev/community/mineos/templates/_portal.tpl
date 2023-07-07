{{- define "mineos.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.mineosNetwork.webPort | quote }}
  protocol: {{ ternary "https" "http" .Values.mineosNetwork.useHTTPS }}
  host: $node_ip
{{- end -}}
