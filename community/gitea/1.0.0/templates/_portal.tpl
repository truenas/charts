{{- define "gitea.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ .Values.giteaNetwork.webPort | quote }}
  {{ if or (hasPrefix "https://" .Values.giteaNetwork.rootURL) .Values.giteaNetwork.certificateID }}
  protocol: https
  {{ else }}
  protocol: http
  {{ end }}
  {{- $host := "$node_ip" -}}
  {{ with .Values.giteaNetwork.rootURL }} {{/* Trim protocol and trailing slash */}}
    {{ $host = (. | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") }}
    {{ $host = mustRegexReplaceAll "(.*):[0-9]+" $host "${1}" }}
  {{ end }}
  host: {{ $host }}
{{- end -}}
