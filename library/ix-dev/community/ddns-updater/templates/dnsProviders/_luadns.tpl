{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/luadns.md */}}
{{- define "ddns.config.luadns" -}}
  {{- $item := .item }}
token: {{ $item.luadnsToken | required "DDNS Updater - Expected non-empty [Token] for LuaDNS provider" }}
email: {{ $item.luadnsEmail | required "DDNS Updater - Expected non-empty [Email] for LuaDNS provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: luadns                  - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      luadnsToken: token                - Required
      luadnsEmail: email@example.com    - Required
*/}}
