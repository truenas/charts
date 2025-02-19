{{- define "passbolt.portal" -}}
  {{- $url := urlParse .Values.passboltConfig.appUrl -}}

  {{- $protocol := "http" -}}
  {{- if $url.scheme -}}
    {{- $protocol = $url.scheme -}}
  {{- end -}}

  {{- $host := "$node_ip" -}}
  {{- $port := ternary "443" "80" (eq $protocol "https") -}}
  {{- if $url.host -}}
    {{- if contains ":" $url.host -}}
      {{- $port = (split ":" $url.host)._1 -}}
      {{- $host = (split ":" $url.host)._0 -}}
    {{- else -}}
      {{- $host = $url.host -}}
    {{- end -}}
  {{- end }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: portal
data:
  path: /
  port: {{ $port | quote }}
  protocol: {{ $protocol | quote }}
  host: {{ $host | quote }}
{{- end -}}
