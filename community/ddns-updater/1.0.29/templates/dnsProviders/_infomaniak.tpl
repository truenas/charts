{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/infomaniak.md */}}
{{- define "ddns.config.infomaniak" -}}
  {{- $item := .item }}
username: {{ $item.infomaniakUsername | required "DDNS Updater - Expected non-empty [Username] for Infomaniak provider" }}
password: {{ $item.infomaniakPassword | required "DDNS Updater - Expected non-empty [Password] for Infomaniak provider" }}
provider_ip: {{ $item.infomaniakProviderIP | default false }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: infomaniak              - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      infomaniakUsername: user          - Required
      infomaniakPassword: password      - Required
      infomaniakProviderIP: true        - Required - Valid values (true/false)
*/}}
