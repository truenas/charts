{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/servercow.md */}}
{{- define "ddns.config.servercow" -}}
  {{- $item := .item }}
username: {{ $item.servercowUsername | required "DDNS Updater - Expected non-empty [Username] for Servercow provider" }}
password: {{ $item.servercowPassword | required "DDNS Updater - Expected non-empty [Password] for Servercow provider" }}
ttl: {{ $item.servercowTtl | required "DDNS Updater - Expected non-empty [TTL] for Servercow provider" }}
provider_ip: {{ $item.servercowProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: servercow               - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      servercowUsername: username       - Required
      servercowPassword: password       - Required
      servercowTtl: 120                 - Required
      servercowProviderIP: false        - Required - Valid values (true/false)
*/}}
