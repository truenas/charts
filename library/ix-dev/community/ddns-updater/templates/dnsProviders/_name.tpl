{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/name.com.md */}}
{{- define "ddns.config.name" -}}
  {{- $item := .item }}
token: {{ $item.nameToken | required "DDNS Updater - Expected non-empty [Token] for Name.com provider" }}
username: {{ $item.nameUsername | required "DDNS Updater - Expected non-empty [Username] for Name.com provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: name                    - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      nameToken: token                  - Required
      nameUsername: username            - Required
*/}}