{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/duckdns.md */}}
{{- define "ddns.config.duckdns" -}}
  {{- $item := .item }}
token: {{ $item.duckdnsToken | required "DDNS Updater - Expected non-empty [Token] for DuckDNS provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: duckdns         - Required
      domain: "example.com"     - Required
      host: "subdomain"         - Required - Valid value (subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      duckdnsToken: token       - Required
*/}}
