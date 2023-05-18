{{/* https://github.com/qdm12/ddns-updater/blob/master/docs/inwx.md */}}
{{- define "ddns.config.inwx" -}}
  {{- $item := .item }}
username: {{ $item.inwxUsername | required "DDNS Updater - Expected non-empty [Username] for INWX provider" }}
password: {{ $item.inwxPassword | required "DDNS Updater - Expected non-empty [Password] for INWX provider" }}
{{- end -}}
{{/*
ddnsConfig:
  config:
    - provider: inwx                    - Required
      domain: "example.com"             - Required
      host: "@"                         - Required - Valid value ("@" or subdomain)
      ipVersion: ""                     - Required - Valid values (ipv4/ipv6/"")
      inwxUsername: user                - Required
      inwxPassword: password            - Required
*/}}
