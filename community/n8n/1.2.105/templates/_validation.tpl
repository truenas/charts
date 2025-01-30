{{- define "n8n.validation" -}}
  {{- $host := .Values.n8nConfig.webHost -}}
  {{- if or (hasPrefix "http://" $host) (hasPrefix "https://" $host) (hasSuffix "/" $host) (contains ":" $host) -}}
    {{- fail "n8n - Do not start with [http(s)://] or have a trailing slash [/] or have port [:###] in [Web Host] field" -}}
  {{- end -}}
{{- end -}}
