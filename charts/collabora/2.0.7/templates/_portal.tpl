{{- define "collabora.portal" -}}
{{- $hasCert := not (empty .Values.collaboraNetwork.certificateID) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  {{- if .Values.collaboraConfig.enableWebUI }}
  path: "/browser/dist/admin/admin.html"
  {{- else }}
  path: "/"
  {{- end }}
  port: {{ .Values.collaboraNetwork.webPort | quote }}
  protocol: {{ ternary "https" "http" $hasCert }}
  host: {{ (split ":" .Values.collaboraConfig.serverName)._0 | default "$node_ip" }}
{{- end -}}
