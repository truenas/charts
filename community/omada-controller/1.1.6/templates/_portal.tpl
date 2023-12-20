{{- define "omada.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: "/"
  port: {{ .Values.omadaNetwork.manageHttpsPort | quote }}
  protocol: https
  host: $node_ip
{{- end -}}
