{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/freedns.md */}}
{{- define "ddns.config.freedns" -}}
  {{- $item := .item }}
token: {{ $item.freeDnsToken | required "DDNS Updater - Expected non-empty [Token] for FreeDNS provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: freedns         - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      freeDnsToken: token       - Required
*/}}
