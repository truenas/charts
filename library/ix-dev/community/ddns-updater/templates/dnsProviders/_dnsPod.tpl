{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dnspod.md */}}
{{- define "ddns.config.dnspod" -}}
  {{- $item := .item }}
token: {{ $item.dnsPodToken | required "DDNS Updater - Expected non-empty [Token] for DNS Pod provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dnspod          - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dnsPodToken: token        - Required
*/}}
