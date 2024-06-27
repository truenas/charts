{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/dynv6.md */}}
{{- define "ddns.config.dynv6" -}}
  {{- $item := .item }}
token: {{ $item.dynv6Token | required "DDNS Updater - Expected non-empty [Token] for DynV6 provider" }}
provider_ip: {{ $item.dynv6ProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: dynu            - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      dynv6Token: token         - Required
      dynv6ProviderIP: true     - Required - Valid values (true/false)
*/}}
