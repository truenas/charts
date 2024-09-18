{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dnsomatic.md */}}
{{- define "ddns.config.dnsomatic" -}}
  {{- $item := .item }}
username: {{ $item.dnsOMaticUsername | required "DDNS Updater - Expected non-empty [Username] for DNS O Matic provider" }}
password: {{ $item.dnsOMaticPassword | required "DDNS Updater - Expected non-empty [Password] for DNS O Matic provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dnsomatic       - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dnsOMaticUsername: user   - Required
      dnsOMaticPassword: pass   - Required
*/}}
