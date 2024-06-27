{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/njalla.md */}}
{{- define "ddns.config.njalla" -}}
  {{- $item := .item }}
key: {{ $item.njallaKey | required "DDNS Updater - Expected non-empty [Key] for Njalla provider" }}
provider_ip: {{ $item.njallaProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: njalla                  - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      njallaKey: key                    - Required
      njallaProviderIP: false           - Required - Valid values (true/false)
*/}}
