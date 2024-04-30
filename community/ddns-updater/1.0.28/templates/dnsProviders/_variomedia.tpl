{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/variomedia.md */}}
{{- define "ddns.config.variomedia" -}}
  {{- $item := .item }}
password: {{ $item.variomediaPassword | required "DDNS Updater - Expected non-empty [Password] for Variomedia provider" }}
email: {{ $item.variomediaEmail | required "DDNS Updater - Expected non-empty [Email] for Variomedia provider" }}
provider_ip: {{ $item.variomediaProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: strato               - Required
      domain: "example.com"          - Required
      host: "@"                      - Required - Valid value ("@" or subdomain)
      ipVersion: ""                  - Required - Valid values (ipv4/ipv6/"")
      variomediaPassword: password   - Required
      variomediaEmail: email         - Required
      variomediaProviderIP: false    - Required - Valid values (true/false)
*/}}
