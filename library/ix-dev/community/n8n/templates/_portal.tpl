{{- define "n8n.portal" -}}
  {{ $prot := "http" }}
  {{ if .Values.n8nNetwork.certificateID }}
    {{ $prot = "https" }}
  {{ end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ .Values.n8nNetwork.webPort | quote }}
  path: "/"
  protocol: {{ $prot }}
  host: $node_ip
{{- end -}}
