{{- define "ipfs.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /webui
  port: {{ .Values.ipfsNetwork.apiPort | quote }}
  protocol: http
  host: $node_ip
{{- end -}}
