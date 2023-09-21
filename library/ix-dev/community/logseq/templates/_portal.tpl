{{- define "logseq.portal" -}}
{{- $protocol := "http" -}}
{{- if .Values.logseqNetwork.certificateID -}}
  {{- $protocol = "https" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.logseqNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: $node_ip
{{- end -}}
