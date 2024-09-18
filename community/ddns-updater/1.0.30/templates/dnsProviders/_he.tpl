{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/he.net.md */}}
{{- define "ddns.config.he" -}}
  {{- $item := .item }}
password: {{ $item.hePassword | required "DDNS Updater - Expected non-empty [Password] for He.net provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: he              - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      hePassword: password      - Required
*/}}
