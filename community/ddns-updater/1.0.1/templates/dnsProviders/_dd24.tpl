{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dd24.md */}}
{{- define "ddns.config.dd24" -}}
  {{- $item := .item }}
password: {{ $item.dd24Password | required "DDNS Updater - Expected non-empty [Password] for dd24 provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dd24            - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dd24Password: pass        - Required
*/}}
