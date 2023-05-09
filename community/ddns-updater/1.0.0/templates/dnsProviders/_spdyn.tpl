{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/spdyn.md */}}
{{- define "ddns.config.spdyn" -}}
  {{- $item := .item }}
{{- if $item.spdynToken }}
token: {{ $item.spdynToken }}
{{- else if and $item.spdynUsername $item.spdynPassword }}
username: {{ $item.spdynUsername }}
password: {{ $item.spdynPassword }}
{{- else -}}
  {{- fail "DDNS Updater - Spdyn.de provider requires either [Token] or [Username and Password]" -}}
{{- end }}
provider_ip: {{ $item.spdynProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: spdyn           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@")
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      spdynProviderIP: false    - Required - Valid values (true/false)

      # One of the following is required
      # Token
      spdynToken: token

      # Username and Password
      spdynUsername: username
      spdynPassword: password
*/}}
