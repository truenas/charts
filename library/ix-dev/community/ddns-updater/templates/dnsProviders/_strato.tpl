{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/strato.md */}}
{{- define "ddns.config.strato" -}}
  {{- $item := .item }}
password: {{ $item.stratoPassword | required "DDNS Updater - Expected non-empty [Password] for Strato provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: strato               - Required
      domain: "example.com"          - Required
      host: "@"                      - Required - Valid value ("@" or subdomain)
      ipVersion: ""                  - Required - Valid values (ipv4/ipv6/"")
      stratoPassword: password       - Required
*/}}
