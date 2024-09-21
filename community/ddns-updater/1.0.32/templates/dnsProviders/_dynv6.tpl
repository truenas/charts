{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dynv6.md */}}
{{- define "ddns.config.dynv6" -}}
  {{- $item := .item }}
token: {{ $item.dynv6Token | required "DDNS Updater - Expected non-empty [Token] for DynV6 provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dynu            - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dynv6Token: token         - Required
*/}}
