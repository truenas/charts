{{- define "n8n.portal" -}}
  {{- $prot := "http" -}}
  {{- if .Values.n8nNetwork.certificateID -}}
    {{- $prot = "https" -}}
  {{- end -}}
  {{- $host := .Values.n8nConfig.webHost | default "$node_ip" -}}
  {{- if contains ":" $host -}}
      {{ $port = (split ":" $host)._1 }}
      {{ $host = (split ":" $host)._0 }}
  {{- end -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.n8nNetwork.webPort | quote }}
  path: "/"
  protocol: {{ $prot }}
  host: {{ $host }}
{{- end -}}
