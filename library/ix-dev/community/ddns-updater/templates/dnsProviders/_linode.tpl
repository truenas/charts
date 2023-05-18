{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/linode.md */}}
{{- define "ddns.config.linode" -}}
  {{- $item := .item }}
token: {{ $item.linodeToken | required "DDNS Updater - Expected non-empty [Token] for Linode provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: linode                  - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      linodeToken: token                - Required
*/}}
