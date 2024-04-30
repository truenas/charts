{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/goip.md */}}
{{- define "ddns.config.goip" -}}
  {{- $item := .item }}
username: {{ $item.goipUsername | required "DDNS Updater - Expected non-empty [Username] for GoIP.de provider" }}
password: {{ $item.goipPassword | required "DDNS Updater - Expected non-empty [Password] for GoIP.de provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: goip           - Required
      domain: "example.com"     - Required
      host: "@"                 - Required - Valid value ("@" or subdomain)
      ipVersion: ""             - Required - Valid values (ipv4/ipv6/"")
      goipDeUsername: user      - Required
      goipDePassword: pass      - Required
*/}}
