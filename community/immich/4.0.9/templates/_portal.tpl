{{- define "immich.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.immichNetwork.webuiPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
