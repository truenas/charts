{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/google.md */}}
{{- define "ddns.config.google" -}}
  {{- $item := .item }}
username: {{ $item.googleUsername | required "DDNS Updater - Expected non-empty [Username] for Google provider" }}
password: {{ $item.googlePassword | required "DDNS Updater - Expected non-empty [Password] for Google provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: google          - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      googleUsername: username  - Required
      googlePassword: password  - Required
*/}}
