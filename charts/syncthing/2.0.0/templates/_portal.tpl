{{- define "syncthing.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.syncthingNetwork.webPort | quote }}
  path: "/"
  protocol: "http"
  host: $node_ip
{{- end -}}
