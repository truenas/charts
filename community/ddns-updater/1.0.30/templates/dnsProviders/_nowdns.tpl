{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/nowdns.md */}}
{{- define "ddns.config.nowdns" -}}
  {{- $item := .item }}
username: {{ $item.nowdnsUsername | required "DDNS Updater - Expected non-empty [Username] for nowdns provider" }}
password: {{ $item.nowdnsPassword | required "DDNS Updater - Expected non-empty [Api Password] for nowdns provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: nowdns         - Required
      domain: "example.com"    - Required
      host: "@"                - Required - Valid value ("@" or subdomain)
      ipVersion: ""            - Required - Valid values (ipv4/ipv6/"")
      nowdnsUsername: pass     - Required
      nowdnsPassword: pass     - Required
*/}}
