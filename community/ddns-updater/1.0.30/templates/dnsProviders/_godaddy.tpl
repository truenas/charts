{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/godaddy.md */}}
{{- define "ddns.config.godaddy" -}}
  {{- $item := .item }}
key: {{ $item.godaddyKey | required "DDNS Updater - Expected non-empty [Key] for GoDaddy provider" }}
secret: {{ $item.godaddySecret | required "DDNS Updater - Expected non-empty [TTL] for GoDaddy provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: godaddy         - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      godaddyKey: key           - Required
      godaddySecret: secret     - Required
*/}}
