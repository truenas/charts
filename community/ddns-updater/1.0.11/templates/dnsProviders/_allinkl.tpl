{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/allinkl.md */}}
{{- define "ddns.config.allinkl" -}}
  {{- $item := .item }}
username: {{ $item.allinklUsername | required "DDNS Updater - Expected non-empty [Username] for All-Inkl provider" }}
password: {{ $item.allinklPassword | required "DDNS Updater - Expected non-empty [Password] for All-Inkl provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: allinkl         - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      allinklUsername: user     - Required
      allinklPassword: password - Required
*/}}
