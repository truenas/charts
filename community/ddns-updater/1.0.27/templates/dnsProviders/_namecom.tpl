{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/name.com.md */}}
{{- define "ddns.config.name.com" -}}
  {{- $item := .item }}
token: {{ $item.namecomToken | required "DDNS Updater - Expected non-empty [Token] for Name.com provider" }}
username: {{ $item.namecomUsername | required "DDNS Updater - Expected non-empty [Username] for Name.com provider" }}
ttl: {{ $item.namecomTtl | required "DDNS Updater - Expected non-empty [TTL] for Name.com provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: name.com                - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      namecomToken: token               - Required
      namecomUsername: username         - Required
      namecomTtl: 300                   - Required - Min Value (300)
*/}}
