{{- define "collabora.portal" -}}
{{- $hasCert := ne (toString .Values.collaboraNetwork.certificateID) "" }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.collaboraNetwork.webPort | quote }}
  protocol: {{ ternary "https" "http" $hasCert }}
  host: {{ (split ":" .Values.collaboraConfig.serverName)._0 | default "$node_ip" }}
{{- end -}}
