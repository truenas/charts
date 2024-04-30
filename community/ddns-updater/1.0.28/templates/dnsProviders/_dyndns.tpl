{{/* https://github.com/qdm12/d-updater/blob/master/docs/dyndns.md */}}
{{- define "ddns.config.dyn" -}}
  {{- $item := .item }}
client_key: {{ $item.dynClientKey | required "DDNS Updater - Expected non-empty [Client Key] for DynDNS provider" }}
username: {{ $item.dynUsername | required "DDNS Updater - Expected non-empty [Username] for DynDNS provider" }}
provider_ip: {{ $item.dynProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dyn             - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dynClientKey: key         - Required
      dynUsername: username     - Required
      dynProviderIP: true       - Required - Valid values (true/false)
*/}}
