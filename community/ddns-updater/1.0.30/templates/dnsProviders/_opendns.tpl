{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/opendns.md */}}
{{- define "ddns.config.opendns" -}}
  {{- $item := .item }}
username: {{ $item.opendnsUsername | required "DDNS Updater - Expected non-empty [Username] for OpenDNS provider" }}
password: {{ $item.opendnsPassword | required "DDNS Updater - Expected non-empty [Password] for OpenDNS provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: opendns                 - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      opendnsUsername: username         - Required
      opendnsPassword: password         - Required
*/}}
