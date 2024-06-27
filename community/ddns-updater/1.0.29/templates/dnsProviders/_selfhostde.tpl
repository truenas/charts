{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/selfhost.de.md */}}
{{- define "ddns.config.selfhost.de" -}}
  {{- $item := .item }}
username: {{ $item.selfhostdeUsername | required "DDNS Updater - Expected non-empty [Username] for Selfhost.de provider" | quote }}
password: {{ $item.selfhostdePassword | required "DDNS Updater - Expected non-empty [Password] for Selfhost.de provider" | quote }}
provider_ip: {{ $item.selfhostdeProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: selfhosted.de           - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      selfhostdeUsername: username      - Required
      selfhostdePassword: password      - Required
      selfhostdeProviderIP: false       - Required - Valid values (true/false)
*/}}
