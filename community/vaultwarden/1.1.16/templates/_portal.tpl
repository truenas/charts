{{- define "vaultwarden.portal" -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  admin_path: /admin
  port: {{ .Values.vaultwardenNetwork.webPort | quote }}

  {{ if or (hasPrefix "https://" .Values.vaultwardenNetwork.domain) .Values.vaultwardenNetwork.certificateID }}
  protocol: https
  {{ else }}
  protocol: http
  {{ end }}

  {{- $host := "$node_ip" -}}
  {{ with .Values.vaultwardenNetwork.domain }} {{/* Trim protocol and trailing slash */}}
    {{ $host = (. | trimPrefix "https://" | trimPrefix "http://" | trimSuffix "/") }}
    {{ $host = mustRegexReplaceAll "(.*):[0-9]+" $host "${1}" }}
  {{ end }}
  host: {{ $host }}
{{- end -}}
