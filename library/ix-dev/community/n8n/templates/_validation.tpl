{{- define "n8n.validation" -}}
  {{- $host := .Values.n8nConfig.webHost -}}
  {{- if or (hasPrefix "http://" $host) (hasPrefix "https://" $host) (hasSuffix "/" $host) -}}
    {{- fail "n8n - Do not start with [http://] or [https://] or have a trailing slash [/] in [Web Host] field" -}}
  {{- end -}}
{{- end -}}
