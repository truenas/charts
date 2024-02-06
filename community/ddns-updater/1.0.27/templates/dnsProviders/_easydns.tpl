{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/easydns.md */}}
{{- define "ddns.config.easydns" -}}
  {{- $item := .item }}
username: {{ $item.easyDnsUsername | required "DDNS Updater - Expected non-empty [Username] for EasyDNS provider" }}
token: {{ $item.easyDnsToken | required "DDNS Updater - Expected non-empty [Token] for EasyDNS provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: easydns         - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      easyDnsUsername: user     - Required
      easyDnsToken: pass        - Required
*/}}
