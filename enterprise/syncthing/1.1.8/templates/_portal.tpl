{{- define "syncthing.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  host: "$node_ip"
  port: {{ .Values.syncthingNetwork.webPort | quote }}
  {{- if .Values.syncthingNetwork.certificateID }}
  protocol: https
  {{- else }}
  protocol: http
  {{- end }}
{{- end -}}
