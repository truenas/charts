{{- define "firefly.portal" -}}
  {{ $prot := "http" }}
  {{ if hasPrefix "https://" .Values.fireflyConfig.appUrl }}
    {{ $prot = "https" }}
  {{ end }}
  {{ $host := "$node_ip" }}
  {{ $port := .Values.fireflyNetwork.webPort }}
  {{ with .Values.fireflyConfig.appUrl }}
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
