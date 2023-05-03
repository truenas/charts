{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dyndns.md */}}
{{- define "ddns.config.dyndns" -}}
  {{- $item := .item }}
client_key: {{ $item.dyndnsClientKey | required "DDNS Updater - Expected non-empty [Client Key] for DynDNS provider" }}
username: {{ $item.dyndnsUsername | required "DDNS Updater - Expected non-empty [Username] for DynDNS provider" }}
provider_ip: {{ $item.dyndnsProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dyndns          - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dyndnsClientKey: key      - Required
      dyndnsUsername: username  - Required
      dyndnsProviderIP: true    - Required - Valid values (true/false)
*/}}
