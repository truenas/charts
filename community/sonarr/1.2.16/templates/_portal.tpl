{{- define "sonarr.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.sonarrNetwork.webPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
