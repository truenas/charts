{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dreamhost.md */}}
{{- define "ddns.config.dreamhost" -}}
  {{- $item := .item }}
key: {{ $item.dreamHostKey | required "DDNS Updater - Expected non-empty [Key] for Dreamhost provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dreamhost       - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dreamHostKey: key         - Required
*/}}
