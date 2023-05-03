{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/selfhosted.de.md */}}
{{- define "ddns.config.selfhosted.de" -}}
  {{- $item := .item }}
username: {{ $item.selfhosteddeUsername | required "DDNS Updater - Expected non-empty [Username] for Selfhosted.de provider" }}
password: {{ $item.selfhosteddePassword | required "DDNS Updater - Expected non-empty [Password] for Selfhosted.de provider" }}
provider_ip: {{ $item.selfhosteddeProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: selfhosted.de           - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      selfhosteddeUsername: username    - Required
      selfhosteddePassword: password    - Required
      selfhosteddeProviderIP: false     - Required - Valid values (true/false)
*/}}
