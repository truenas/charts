{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/noip.md */}}
{{- define "ddns.config.noip" -}}
  {{- $item := .item }}
username: {{ $item.noipUsername | required "DDNS Updater - Expected non-empty [Username] for NoIP provider" }}
password: {{ $item.noipPassword | required "DDNS Updater - Expected non-empty [Password] for NoIP provider" }}
provider_ip: {{ $item.noipProviderIP }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: noip                    - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      noipUsername: username            - Required
      noipPassword: password            - Required
      noipProviderIP: false             - Required - Valid values (true/false)
*/}}
