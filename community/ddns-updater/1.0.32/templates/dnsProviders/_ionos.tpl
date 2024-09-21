{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/ionos.md */}}
{{- define "ddns.config.ionos" -}}
  {{- $item := .item }}
api_key: {{ $item.ionosApiKey | required "DDNS Updater - Expected non-empty [Api Key] for ionos provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: ionos           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      ionosApiKey: pass         - Required
*/}}
