{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/namecheap.md */}}
{{- define "ddns.config.namecheap" -}}
  {{- $item := .item }}
password: {{ $item.namecheapPassword | required "DDNS Updater - Expected non-empty [Password] for Namecheap provider" }}
provider_ip: {{ $item.namecheapProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: namecheap               - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      namecheapPassword: password       - Required
      namecheapProviderIP: false        - Required - Valid values (true/false)
*/}}
