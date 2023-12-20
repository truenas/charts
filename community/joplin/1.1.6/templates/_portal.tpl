{{- define "joplin.portal" -}}
  {{ $prot := "http" }}
  {{ if hasPrefix "https://" .Values.joplinConfig.baseUrl }}
    {{ $prot = "https" }}
  {{ end }}
  {{ $host := "$node_ip" }}
  {{ $port := .Values.joplinNetwork.webPort }}
  {{ with .Values.joplinConfig.baseUrl }}
    {{ $host = . | trimPrefix "http://" | trimPrefix "https://" | trimSuffix "/" }}
    {{ if contains ":" $host }}
      {{ $port = (split ":" $host)._1 }}
      {{ $host = (split ":" $host)._0 }}
    {{ end }}
  {{ end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  port: {{ $port | quote }}
  path: "/"
  protocol: {{ $prot }}
  host: {{ $host }}
{{- end -}}
