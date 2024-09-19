{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/digitalocean.md */}}
{{- define "ddns.config.digitalocean" -}}
  {{- $item := .item }}
token: {{ $item.digitalOceanToken | required "DDNS Updater - Expected non-empty [Token] for Digital Ocean provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: digitalocean    - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      digitalOceanToken: token  - Required
*/}}
