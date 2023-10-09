{{- define "drawio.portal" -}}
{{- $path := "/?offline=1" -}}
{{- $protocol := "https" -}}
{{- if .Values.drawioNetwork.useHttp -}}
  {{- $path = printf "%s&https=0" $path -}}
  {{- $protocol = "http" -}}
{{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: {{ $path }}
  port: {{ .Values.drawioNetwork.webPort | quote }}
  protocol: {{ $protocol }}
  host: $node_ip
{{- end -}}
