{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/desec.md */}}
{{- define "ddns.config.desec" -}}
  {{- $item := .item }}
token: {{ $item.desecToken | required "DDNS Updater - Expected non-empty [Token] for desec provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: desec           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      desecToken: pass          - Required
*/}}
