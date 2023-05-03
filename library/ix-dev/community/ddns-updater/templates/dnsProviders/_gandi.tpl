{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/gandi.md */}}
{{- define "ddns.config.gandi" -}}
  {{- $item := .item }}
key: {{ $item.gandiKey | required "DDNS Updater - Expected non-empty [Key] for Gandi provider" }}
ttl: {{ $item.gandiTtl | required "DDNS Updater - Expected non-empty [TTL] for Gandi provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: gandi           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      gandiKey: key             - Required
      gandiTtl: 3600            - Required
*/}}
